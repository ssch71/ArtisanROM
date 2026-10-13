# Skip NandswapManager init in StorageManagerService (H_SYSTEM_READY).
# On this 4.19 kernel the StorageManagerService handler thread stops after
# H_SYSTEM_READY, so emulated;0 is never mounted at boot (experimental).
DECODE_APK "system" "system/framework/services.jar"
# the class may live in smali, smali_classes2, ... depending on the dex split
SMALI_FILE="$(find "$APKTOOL_DIR/system/system/framework/services.jar" -type f \
    -path "*/com/android/server/StorageManagerService\$Callbacks.smali" | head -n 1)"
if [ -z "$SMALI_FILE" ] || [ ! -f "$SMALI_FILE" ]; then
    ABORT "File not found: StorageManagerService\$Callbacks.smali in services.jar"
fi

LOG "- Skipping NandswapManager init in StorageManagerService"
python3 - "$SMALI_FILE" <<'PY' || ABORT "Failed to patch StorageManagerService\$Callbacks"
import re, sys

path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    lines = fh.read().split("\n")

marker = next((i for i, l in enumerate(lines) if '"Initialize NandswapManager..."' in l), None)
if marker is None:
    sys.exit("marker not found")

log_idx = next((i for i in range(marker, marker + 8) if "Landroid/util/Slog;->d(" in lines[i]), None)
if log_idx is None:
    sys.exit("Slog call not found")
if "goto" in lines[log_idx + 2]:
    sys.exit(0)  # already patched

zram = next((i for i in range(log_idx, len(lines)) if 'const-string/jumbo v2, "zram_enabled"' in lines[i]), None)
if zram is None:
    sys.exit("zram_enabled not found")

# label names differ between baksmali versions, so look it up
label = None
for i in range(zram, log_idx, -1):
    m = re.match(r"^\s+:(goto_\w+)\s*$", lines[i])
    if m:
        label = m.group(1)
        break
if label is None:
    sys.exit("jump label not found")

lines[log_idx + 1:log_idx + 1] = ["", "    goto :" + label]
with open(path, "w", encoding="utf-8") as fh:
    fh.write("\n".join(lines))
print("goto :" + label)
PY
unset SMALI_FILE
