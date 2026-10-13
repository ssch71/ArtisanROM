# Skip the MediaCodecList HEVC probe in StorageManagerService (H_SYSTEM_READY).
# The call blocks forever in media.player getCodecList on this device, which
# stalls the StorageManagerService handler thread: no automatic mount of
# emulated;0 and MediaProvider never gets external_primary.
DECODE_APK "system" "system/framework/services.jar"
# Locate the decoded class (dir layout/dex split can differ), searching the whole apktool dir
SMALI_FILE="$(find "$APKTOOL_DIR" -type f \
    -path "*/services.jar/*/com/android/server/StorageManagerService\$Callbacks.smali" 2> /dev/null | head -n 1)"
if [ -z "$SMALI_FILE" ] || [ ! -f "$SMALI_FILE" ]; then
    LOGW "APKTOOL_DIR=$APKTOOL_DIR"
    LOGW "$(find "$APKTOOL_DIR" -maxdepth 4 -name 'services.jar*' 2> /dev/null | head -n 5)"
    ABORT "File not found: StorageManagerService\$Callbacks.smali in services.jar"
fi

LOG "- Skipping MediaCodecList HEVC probe in StorageManagerService"
python3 - "$SMALI_FILE" <<'PY' || ABORT "Failed to patch StorageManagerService\$Callbacks"
import re, sys

path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    lines = fh.read().split("\n")

new_inst = next((i for i, l in enumerate(lines) if "new-instance v0, Landroid/media/MediaCodecList;" in l), None)
if new_inst is None:
    sys.exit("MediaCodecList block not found")

prev = next((i for i in range(new_inst - 1, new_inst - 6, -1) if lines[i].strip()), None)
if prev is not None and lines[prev].strip().startswith("goto :"):
    sys.exit(0)  # already patched

prop = next((i for i in range(new_inst, len(lines))
             if '"persist.sys.fuse.transcode_user_control"' in lines[i]), None)
if prop is None:
    sys.exit("transcode_user_control not found")

# the label directly in front of the property lookup (end of the HEVC probe)
label = None
for i in range(prop - 1, new_inst, -1):
    s = lines[i].strip()
    if not s:
        continue
    m = re.match(r"^:(goto_\w+)$", s)
    if m:
        label = m.group(1)
    break
if label is None:
    sys.exit("jump label not found")

lines[new_inst:new_inst] = ["    goto :" + label, ""]
with open(path, "w", encoding="utf-8") as fh:
    fh.write("\n".join(lines))
print("goto :" + label)
PY
unset SMALI_FILE
