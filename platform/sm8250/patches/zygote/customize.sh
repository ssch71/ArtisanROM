# The legacy SM8250 vendor sets ro.zygote=zygote64_32 and advertises 32-bit
# ABIs, but a 64-bit-only source only ships init.zygote64.rc. Without a fix
# init defines no zygote at all, and with only ro.zygote fixed system_server
# loops trying to reach the missing zygote_secondary socket.
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

# 64-bit-only zygote: advertise 64-bit ABIs only, like the source does.
if [ ! -f "$HW_INIT/init.zygote64_32.rc" ]; then
    for PART in vendor odm; do
        for F in "$WORK_DIR/$PART/build.prop" "$WORK_DIR/$PART/etc/build.prop"; do
            [ -f "$F" ] || continue
            if grep -q "^ro.$PART.product.cpu.abilist=" "$F"; then
                LOG "- Making ${F//$WORK_DIR/} 64-bit only"
                sed -i -E \
                    -e "s/^(ro\.$PART\.product\.cpu\.abilist)=.*/\1=arm64-v8a/" \
                    -e "s/^(ro\.$PART\.product\.cpu\.abilist32)=.*/\1=/" "$F"
            fi
            sed -i -E -e 's/^(ro\.product\.cpu\.abilist)=.*/\1=arm64-v8a/' \
                -e 's/^(ro\.product\.cpu\.abilist32)=.*/\1=/' "$F"
        done
    done
fi
unset HW_INIT CURRENT PART F
