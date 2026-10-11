# ARM32 system runtime for SM8250 targets.
# The S24U (S928B) Android 16 source is 64-bit-only, but the target R vendor
# still runs 32-bit services (boringssl_self_test32, OMX, audio, QC daemons).
# Import the complete 32-bit system userspace (system/lib + multilib Runtime,
# I18n and ART APEXes) from a multilib Android 16 donor: dm1qksx (S23, One UI 8.5).
DONOR="dm1qksx"
DONOR_DIR="$SRC_DIR/prebuilts/samsung/$DONOR/system"

if [ -e "$WORK_DIR/system/system/bin/linker" ] || [ -L "$WORK_DIR/system/system/bin/linker" ]; then
    LOG "- Source already ships a 32-bit runtime; skipping"
    return 0
fi
if [ ! -d "$DONOR_DIR/lib" ]; then
    ABORT "32-bit donor not found: prebuilts/samsung/$DONOR/system/lib"
fi

LOG_STEP_IN "- Adding ARM32 system runtime from $DONOR"

FS_CONFIG="$WORK_DIR/configs/fs_config-system"
FILE_CONTEXT="$WORK_DIR/configs/file_context-system"
ESCAPE() { sed -e 's/[.+]/\\&/g' <<< "$1"; }
ADD_ENTRY()
{
    # $1: path relative to the system partition root (system/...), $2: mode, $3: label
    grep -q -F "$1 " "$FS_CONFIG" 2> /dev/null || echo "$1 0 0 $2 capabilities=0x0" >> "$FS_CONFIG"
    grep -q -F "/$(ESCAPE "$1") " "$FILE_CONTEXT" 2> /dev/null || echo "/$(ESCAPE "$1") $3" >> "$FILE_CONTEXT"
}

# 1) Multilib Runtime / I18n / ART APEXes replace the 64-bit-only ones
for KEY in "com.android.runtime" "com.android.i18n" "android.art"; do
    DONOR_APEX="$(find "$DONOR_DIR/apex" -maxdepth 1 -name "*$KEY*" ! -name '*.0[1-9]' ! -name '*.[1-9][0-9]' 2> /dev/null | head -n 1)"
    if [ -z "$DONOR_APEX" ]; then
        DONOR_APEX="$(find "$SRC_DIR/prebuilts/samsung/r11sxxx/system/apex" -maxdepth 1 -name "*$KEY*" ! -name '*.0[1-9]' ! -name '*.[1-9][0-9]' 2> /dev/null | head -n 1)"
        [ -n "$DONOR_APEX" ] && LOGW "- $DONOR has no $KEY APEX, falling back to r11sxxx"
    fi
    if [ -z "$DONOR_APEX" ]; then
        ABORT "No multilib $KEY APEX available"
    fi
    NAME="$(basename "${DONOR_APEX%.00}")"
    for OLD in "$WORK_DIR/system/system/apex/"*"$KEY"*; do
        [ -e "$OLD" ] || continue
        LOG "- Removing 64-bit-only ${OLD//$WORK_DIR/}"
        rm -f "$OLD"
    done
    LOG "- Adding /system/system/apex/$NAME"
    if [[ "$DONOR_APEX" == *.00 ]]; then
        cat "${DONOR_APEX%.00}".[0-9][0-9] > "$WORK_DIR/system/system/apex/$NAME"
    else
        cp -a "$DONOR_APEX" "$WORK_DIR/system/system/apex/$NAME"
    fi
    ADD_ENTRY "system/apex/$NAME" 644 "u:object_r:system_file:s0"
done

# 2) Complete /system/lib, without overwriting anything the build already has
COUNT=0
mkdir -p "$WORK_DIR/system/system/lib"
ADD_ENTRY "system/lib" 755 "u:object_r:system_lib_file:s0"
while IFS= read -r -d '' SRC; do
    REL="${SRC#$DONOR_DIR/}"
    case "$REL" in *.0[1-9]|*.[1-9][0-9]) continue ;; esac
    case "$REL" in lib/libc.so|lib/libdl.so|lib/libdl_android.so|lib/libm.so) continue ;; esac
    REL="${REL%.00}"
    DST="$WORK_DIR/system/system/$REL"
    if [ -d "$SRC" ] && [ ! -L "$SRC" ]; then
        mkdir -p "$DST"
        ADD_ENTRY "system/$REL" 755 "u:object_r:system_lib_file:s0"
        continue
    fi
    [ -e "$DST" ] || [ -L "$DST" ] && continue
    mkdir -p "$(dirname "$DST")"
    if [[ "$SRC" == *.00 ]]; then
        cat "${SRC%.00}".[0-9][0-9] > "$DST"
    else
        cp -a "$SRC" "$DST"
    fi
    ADD_ENTRY "system/$REL" 644 "u:object_r:system_lib_file:s0"
    COUNT=$((COUNT + 1))
done < <(find "$DONOR_DIR/lib" -mindepth 1 -print0 | sort -z)
LOG "- Imported $COUNT 32-bit system libraries"

# 3) Legacy HIDL audio glue only the target system has (if the donor lacks it)
TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"
while IFS= read -r LIB; do
    [ "$LIB" ] || continue
    [ -e "$WORK_DIR/system/system/lib/$LIB" ] && continue
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib/$LIB" 0 0 644 "u:object_r:system_lib_file:s0"
done < <(find "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/lib" -maxdepth 1 \
    -name 'android.hardware.audio*@*.so' -printf '%f\n' 2> /dev/null | sort)

# 4) Standard multilib runtime links
for ENTRY in \
    "system/bin/linker|/apex/com.android.runtime/bin/linker|755|u:object_r:system_linker_exec:s0" \
    "system/bin/linker_asan|/apex/com.android.runtime/bin/linker|755|u:object_r:system_file:s0" \
    "system/lib/libc.so|/apex/com.android.runtime/lib/bionic/libc.so|644|u:object_r:system_lib_file:s0" \
    "system/lib/libdl.so|/apex/com.android.runtime/lib/bionic/libdl.so|644|u:object_r:system_lib_file:s0" \
    "system/lib/libdl_android.so|/apex/com.android.runtime/lib/bionic/libdl_android.so|644|u:object_r:system_lib_file:s0" \
    "system/lib/libm.so|/apex/com.android.runtime/lib/bionic/libm.so|644|u:object_r:system_lib_file:s0"; do
    IFS='|' read -r REL TGT MODE LABEL <<< "$ENTRY"
    LINK="$WORK_DIR/system/$REL"
    rm -f "$LINK"
    mkdir -p "$(dirname "$LINK")"
    ln -sfn "$TGT" "$LINK"
    if grep -q -F "$REL " "$FS_CONFIG" 2> /dev/null; then
        sed -i "\|^$REL |d" "$FS_CONFIG"
    fi
    echo "$REL 0 2000 $MODE capabilities=0x0" >> "$FS_CONFIG"
    grep -q -F "/$(ESCAPE "$REL") " "$FILE_CONTEXT" 2> /dev/null || echo "/$(ESCAPE "$REL") $LABEL" >> "$FILE_CONTEXT"
done

unset DONOR DONOR_DIR FS_CONFIG FILE_CONTEXT KEY DONOR_APEX NAME OLD COUNT SRC REL DST \
    TARGET_FIRMWARE_PATH LIB ENTRY TGT MODE LABEL LINK
unset -f ESCAPE ADD_ENTRY
LOG_STEP_OUT
