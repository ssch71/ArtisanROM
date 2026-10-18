# Copyright (c) 2026 ssch71
# SPDX-License-Identifier: GPL-3.0-or-later

# Replace stock system apps with the latest Galaxy Store builds.
# Format: "<package>|<dir name candidates...>"
# Only apps that already exist in the work dir are swapped; anything else is skipped.
STORE_SWAP_APPS=(
    # Default apps
    "com.sec.android.app.sbrowser|SBrowser SBrowser_Beta"
    "com.samsung.android.app.notes|SamsungNotes Notes SamsungNote"
    "com.samsung.android.calendar|SamsungCalendar Calendar"
    "com.sec.android.app.clockpackage|ClockPackage"
    "com.sec.android.app.popupcalculator|SamsungCalculator PopupCalculator Calculator"
    "com.sec.android.app.myfiles|SecMyFiles2020 SecMyFiles MyFiles"
    # Launcher / keyboard
    "com.sec.android.app.launcher|TouchWizHome_2017 TouchWizHome"
    "com.samsung.android.honeyboard|HoneyBoard"
)

# Apps that are not part of the stock image: added as preload (user-removable) apps.
# Format: "<package>|<dir name>"
STORE_PRELOAD_APPS=(
    "com.samsung.android.goodlock|GoodLock"
)

_STORE_FETCH()
{
    local PACKAGE="$1"
    local OUTPUT="$2"
    local URL

    if ! URL="$(GET_GALAXY_STORE_DOWNLOAD_URL "$PACKAGE")" || [ -z "$URL" ]; then
        LOGW "No Galaxy Store build found for $PACKAGE, skipping"
        return 1
    fi

    rm -f "$OUTPUT"
    if ! DOWNLOAD_FILE "$URL" "$OUTPUT" > /dev/null 2>&1; then
        LOGW "Download failed for $PACKAGE, skipping"
        rm -f "$OUTPUT"
        return 1
    fi

    # Reject HTML error pages / truncated downloads
    if ! unzip -tqq "$OUTPUT" > /dev/null 2>&1 || ! unzip -l "$OUTPUT" 2> /dev/null | grep -q "AndroidManifest.xml"; then
        LOGW "Downloaded file for $PACKAGE is not a valid APK, skipping"
        rm -f "$OUTPUT"
        return 1
    fi

    return 0
}

STORE_TMP="$(mktemp -d)"

for ENTRY in "${STORE_SWAP_APPS[@]}"; do
    PKG="${ENTRY%%|*}"
    APK=""
    for NAME in ${ENTRY#*|}; do
        for PART in priv-app app preload; do
            if [ -f "$WORK_DIR/system/system/$PART/$NAME/$NAME.apk" ]; then
                APK="system/$PART/$NAME/$NAME.apk"
                break 2
            fi
        done
    done

    if [ -z "$APK" ]; then
        LOG "- $PKG not found in system, skipping"
        continue
    fi

    LOG "- Swapping $APK with latest Galaxy Store build ($PKG)"
    if _STORE_FETCH "$PKG" "$STORE_TMP/$PKG.apk"; then
        mv -f "$STORE_TMP/$PKG.apk" "$WORK_DIR/system/$APK"
        # Stale prebuilt odex/vdex would not match the new APK
        if [ -d "$WORK_DIR/system/$(dirname "$APK")/oat" ]; then
            rm -rf "$WORK_DIR/system/$(dirname "$APK")/oat"
        fi
    fi
done

for ENTRY in "${STORE_PRELOAD_APPS[@]}"; do
    PKG="${ENTRY%%|*}"
    NAME="${ENTRY#*|}"
    APK="system/preload/$NAME/$NAME.apk"

    LOG "- Adding $PKG to preload apps"
    if _STORE_FETCH "$PKG" "$STORE_TMP/$PKG.apk"; then
        mkdir -p "$WORK_DIR/system/system/preload/$NAME"
        mv -f "$STORE_TMP/$PKG.apk" "$WORK_DIR/system/$APK"
        SET_METADATA "system" "system/preload/$NAME" 0 0 755 "u:object_r:system_file:s0"
        SET_METADATA "system" "$APK" 0 0 644 "u:object_r:system_file:s0"
        if [ -f "$WORK_DIR/system/system/etc/vpl_apks_count_list.txt" ] && \
                ! grep -q "$APK" "$WORK_DIR/system/system/etc/vpl_apks_count_list.txt"; then
            echo "$APK" >> "$WORK_DIR/system/system/etc/vpl_apks_count_list.txt"
        fi
    fi
done

rm -rf "$STORE_TMP"
unset STORE_SWAP_APPS STORE_PRELOAD_APPS STORE_TMP ENTRY PKG APK NAME PART
unset -f _STORE_FETCH
