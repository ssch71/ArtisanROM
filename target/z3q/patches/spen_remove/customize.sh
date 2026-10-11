# Remove the S Pen stack inherited from the source firmware (S24U) on
# targets without an S Pen. sm8250 debloat already drops the AirCommand
# privapp permission XMLs and pensounds, so leftover S Pen priv-apps would be
# missing their allowlist entries.
TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"
if [ -d "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/media/audio/pensounds" ]; then
    LOG "- Target has an S Pen, keeping S Pen stack"
else
    SPEN_REGEX='^(AirCommand.*|AirGlance|AirReadingGlass|SmartEye|LiveDrawing|PenUp.*|.*S[Pp]en.*|.*DirectWriting.*)$'
    for PART in system product system_ext; do
        for SUB in app priv-app; do
            if [ "$PART" = "system" ]; then
                REL="system/$SUB"
                BASE="$WORK_DIR/system/system/$SUB"
            elif [ "$PART" = "system_ext" ] && [ ! -d "$WORK_DIR/system_ext" ]; then
                REL="$SUB"
                BASE="$WORK_DIR/system/system/system_ext/$SUB"
            else
                REL="$SUB"
                BASE="$WORK_DIR/$PART/$SUB"
            fi
            [ -d "$BASE" ] || continue
            for DIR in "$BASE"/*/; do
                [ -d "$DIR" ] || continue
                NAME="$(basename "$DIR")"
                if [[ "$NAME" =~ $SPEN_REGEX ]]; then
                    DELETE_FROM_WORK_DIR "$PART" "$REL/$NAME"
                fi
            done
        done
    done

    for FILE in \
        "system/etc/default-permissions/default-permissions-com.samsung.android.service.aircommand.xml" \
        "system/etc/permissions/privapp-permissions-com.samsung.android.app.readingglass.xml" \
        "system/etc/permissions/privapp-permissions-com.samsung.android.service.aircommand.xml" \
        "system/etc/permissions/privapp-permissions-com.samsung.android.service.airviewdictionary.xml" \
        "system/etc/permissions/com.sec.feature.spen_usp.xml" \
        "system/etc/permissions/com.sec.feature.spen_usp_level40.xml" \
        "system/etc/permissions/com.sec.feature.spen_bluetooth.xml" \
        "system/etc/sysconfig/airviewdictionaryservice.xml" \
        "system/media/audio/pensounds"; do
        if [ -e "$WORK_DIR/system/$FILE" ]; then
            DELETE_FROM_WORK_DIR "system" "$FILE"
        fi
    done

    # Leftovers worth checking in the build log
    find "$WORK_DIR/system/system" "$WORK_DIR/product" "$WORK_DIR/system_ext" -maxdepth 3 \
        \( -iname '*spen*' -o -iname '*aircommand*' -o -iname '*pensound*' \) 2> /dev/null \
        | sed "s#$WORK_DIR#    - Remaining S Pen-like entry: #" || true
fi
unset TARGET_FIRMWARE_PATH SPEN_REGEX PART SUB REL BASE DIR NAME FILE
