# The legacy SM8250 vendor sets ro.zygote=zygote64_32, but a 64-bit-only
# source only ships init.zygote64.rc. init then defines no zygote service at
# all and the device hangs at the boot logo.
HW_INIT="$WORK_DIR/system/system/etc/init/hw"
CURRENT="$(grep -h "^ro.zygote=" "$WORK_DIR/vendor/build.prop" "$WORK_DIR/vendor/default.prop" 2> /dev/null | tail -n 1 | cut -d= -f2)"
LOG "- vendor ro.zygote: ${CURRENT:-unset}"
if [ -n "$CURRENT" ] && [ ! -f "$HW_INIT/init.$CURRENT.rc" ]; then
    if [ -f "$HW_INIT/init.zygote64.rc" ]; then
        SET_PROP "vendor" "ro.zygote" "zygote64"
    else
        ABORT "No zygote init script for ro.zygote=$CURRENT"
    fi
fi
unset HW_INIT CURRENT
