# The target vendor runs boringssl self tests that are declared with
# "reboot_on_failure reboot,boringssl-self-check-failed". With a 64-bit-only
# Android 16 source one of them can't run on the legacy SM8250 vendor and init
# reboots before anything is logged. Keep the self tests but drop the forced
# reboot, and log every self test service and whether its binary exists.
SYSTEM_EXT_ROOT="$WORK_DIR/system/system/system_ext"
[ -d "$WORK_DIR/system_ext" ] && SYSTEM_EXT_ROOT="$WORK_DIR/system_ext"

RC_FILES="$(grep -rlE "reboot_on_failure[[:space:]]+reboot,boringssl-self-check-failed" \
    "$WORK_DIR/system/system/etc/init" "$SYSTEM_EXT_ROOT/etc/init" \
    "$WORK_DIR/product/etc/init" "$WORK_DIR/vendor/etc/init" "$WORK_DIR/odm/etc/init" 2> /dev/null)"

while read -r RC; do
    [ "$RC" ] || continue
    while read -r SVC BIN; do
        case "$BIN" in
            /system_ext/*) CHECK="$SYSTEM_EXT_ROOT/${BIN#/system_ext/}" ;;
            /system/*) CHECK="$WORK_DIR/system$BIN" ;;
            /vendor/*|/product/*|/odm/*) CHECK="$WORK_DIR$BIN" ;;
            *) CHECK="" ;;
        esac
        if [ -z "$CHECK" ]; then
            LOG "- $SVC: $BIN (inside APEX, not checked)"
        elif [ -f "$CHECK" ]; then
            LOG "- $SVC: $BIN ($(file -b "$CHECK" | cut -d, -f1-2))"
        else
            LOGW "- $SVC: $BIN is MISSING"
        fi
    done < <(grep -E "^service[[:space:]]+[^[:space:]]*boringssl[^[:space:]]*[[:space:]]" "$RC" | awk '{print $2, $3}')
    LOG "- Dropping boringssl reboot_on_failure from ${RC//$WORK_DIR/}"
    sed -i -E '/reboot_on_failure[[:space:]]+reboot,boringssl-self-check-failed/d' "$RC"
done <<< "$RC_FILES"

unset SYSTEM_EXT_ROOT RC_FILES RC SVC BIN CHECK
