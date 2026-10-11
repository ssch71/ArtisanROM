# Drop system_ext/product mapping lines that reference versioned attributes
# (e.g. vendor_smcinvoke_device_30_0) which no policy file declares.
# The source firmware's mappings list QC vendor types the target's vendor
# policy doesn't know, and init's secilc then fails to compile the policy.
VER="$(cat "$WORK_DIR/vendor/etc/selinux/plat_sepolicy_vers.txt" 2>/dev/null)"
if [ -n "$VER" ]; then
    SUFFIX="_${VER//./_}"
    SYSTEM_EXT_SE="$WORK_DIR/system/system/system_ext/etc/selinux"
    [ -d "$WORK_DIR/system_ext/etc/selinux" ] && SYSTEM_EXT_SE="$WORK_DIR/system_ext/etc/selinux"
    ALL_CIL="$(find "$WORK_DIR/system/system/etc/selinux" "$SYSTEM_EXT_SE" "$WORK_DIR/product/etc/selinux" \
        "$WORK_DIR/vendor/etc/selinux" "$WORK_DIR/odm/etc/selinux" -name "*.cil" 2> /dev/null)"
    for MAPPING in "$SYSTEM_EXT_SE/mapping/$VER.cil" "$WORK_DIR/product/etc/selinux/mapping/$VER.cil"; do
        [ -f "$MAPPING" ] || continue
        while IFS= read -r ATTR; do
            # shellcheck disable=SC2086
            if ! grep -q -E "^\(typeattribute $ATTR\)" $ALL_CIL; then
                LOG "- Removing undeclared $ATTR from ${MAPPING//$WORK_DIR/}"
                EVAL "sed -i -E '/\\(expandtypeattribute \\($ATTR\\)|\\(typeattributeset $ATTR /d' \"$MAPPING\""
            fi
        done < <(grep -oE "\(expandtypeattribute \([a-z0-9_]+$SUFFIX\)" "$MAPPING" | sed -E 's/.*\(([a-z0-9_]+)\)$/\1/' | sort -u)
    done
fi
unset VER SUFFIX SYSTEM_EXT_SE ALL_CIL MAPPING ATTR
