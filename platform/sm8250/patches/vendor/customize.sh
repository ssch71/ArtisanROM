LOG_STEP_IN "- Replacing vibrator blobs with a73xqxx"
DELETE_FROM_WORK_DIR "vendor" "bin/hw/vendor.samsung.hardware.vibrator@2.2-service"
DELETE_FROM_WORK_DIR "vendor" "etc/init/vendor.samsung.hardware.vibrator@2.2-service.rc"
DELETE_FROM_WORK_DIR "vendor" "lib64/vendor.samsung.hardware.vibrator@2.0.so"
DELETE_FROM_WORK_DIR "vendor" "lib64/vendor.samsung.hardware.vibrator@2.1.so"
DELETE_FROM_WORK_DIR "vendor" "lib64/vendor.samsung.hardware.vibrator@2.2.so"

ADD_TO_WORK_DIR "a73xqxx" "vendor" "bin/hw/vendor.samsung.hardware.vibrator-service" 0 2000 755 "u:object_r:hal_vibrator_default_exec:s0"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "etc/init/vendor.samsung.hardware.vibrator-default.rc" 0 0 644 "u:object_r:vendor_configs_file:s0"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "etc/vintf/manifest/vendor.samsung.hardware.vibrator-default.xml" 0 0 644 "u:object_r:vendor_configs_file:s0"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "lib64/vendor.samsung.hardware.vibrator-V3-ndk_platform.so" 0 0 644 "u:object_r:vendor_configs_file:s0"
LOG_STEP_OUT

if [[ "$TARGET_CODENAME" == "x1q" || \
      "$TARGET_CODENAME" == "y2q" || \
      "$TARGET_CODENAME" == "z3q" || \
      "$TARGET_CODENAME" == "c1q" || \
      "$TARGET_CODENAME" == "c2q" ]]; then
    LOG_STEP_IN "- Adding dm3qxxx light blobs"
    ADD_TO_WORK_DIR "dm3qxxx" "vendor" "bin/hw/vendor.samsung.hardware.light-service"
    ADD_TO_WORK_DIR "dm3qxxx" "vendor" "lib64/vendor.samsung.hardware.light-V1-ndk_platform.so"
    LOG_STEP_OUT
fi

if [[ "$TARGET_CODENAME" == "x1q" || \
      "$TARGET_CODENAME" == "y2q" || \
      "$TARGET_CODENAME" == "z3q" || \
      "$TARGET_CODENAME" == "c1q" || \
      "$TARGET_CODENAME" == "c2q" ]]; then
    LOG_STEP_IN "- Adding dm3qxxx wifi blobs"
    ADD_TO_WORK_DIR "dm3qxxx" "vendor" "bin/hw/wpa_supplicant" 0 2000 755 "u:object_r:hal_wifi_supplicant_default_exec:s0"
    LOG_STEP_OUT
fi

LOG_STEP_IN "- Adding 32-bit WFD blobs"
DELETE_FROM_WORK_DIR "system" "system/lib64/libhdcp_client_aidl.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libhdcp2.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libremotedisplay_wfd.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libremotedisplayservice.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libsecuibc.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/libstagefright_hdcp.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/vendor.samsung.hardware.security.hdcp.wifidisplay-V2-ndk.so"
DELETE_FROM_WORK_DIR "system" "system/lib64/wfd_log.so"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/bin/insthk" 0 2000 755 "u:object_r:insthk_exec:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/bin/remotedisplay" 0 2000 755 "u:object_r:remotedisplay_exec:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib/libhdcp2.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib/libremotedisplay_wfd.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib/libremotedisplayservice.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib/libsecuibc.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib/libstagefright_hdcp.so" 0 0 644 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib/wfd_log.so" 0 0 644 "u:object_r:system_lib_file:s0"

echo "Remove DualDAR mount points"
sed -i "/keydata/d" "$WORK_DIR/vendor/etc/fstab.qcom"
sed -i "/keyrefuge/d" "$WORK_DIR/vendor/etc/fstab.qcom"

LOG_STEP_IN "- Setting Adaptive HFR flags"
    SET_PROP "vendor" "debug.sf.show_refresh_rate_overlay_render_rate" "true"
    SET_PROP "vendor" "ro.surface_flinger.game_default_frame_rate_override" "60"
    SET_PROP "vendor" "ro.surface_flinger.use_content_detection_for_refresh_rate" "true"
    SET_PROP "vendor" "ro.surface_flinger.set_idle_timer_ms" "250"
    SET_PROP "vendor" "ro.surface_flinger.set_touch_timer_ms" "300"
    SET_PROP "vendor" "ro.surface_flinger.set_display_power_timer_ms" "200"
    SET_PROP "vendor" "ro.surface_flinger.enable_frame_rate_override" "true"
LOG_STEP_OUT

LOG_STEP_IN "- Enabling Vulkan"
SET_PROP "vendor" "ro.hwui.use_vulkan" "true"
LOG_STEP_OUT

LOG_STEP_IN "- wifi+security Prop"
SET_PROP "vendor" "wlan.wfd.hdcp" "disabled"
SET_PROP "vendor" "wifi.interface" "wlan0"
SET_PROP "vendor" "ro.security.vaultkeeper.native" "0"
SET_PROP "vendor" "ro.security.vaultkeeper.feature" "0"
LOG_STEP_OUT

LOG_STEP_IN "- Replacing singletake blobs with dm3qxxx"
DELETE_FROM_WORK_DIR "vendor" "etc/singletake"
ADD_TO_WORK_DIR "dm3qxxx" "vendor" "etc/singletake" 0 0 755 "u:object_r:vendor_file:s0"
LOG_STEP_OUT

LOG_STEP_IN "- Removing configstore-1.1 service"
DELETE_FROM_WORK_DIR "vendor" "bin/hw/android.hardware.configstore@1.1-service"
DELETE_FROM_WORK_DIR "vendor" "etc/init/android.hardware.configstore@1.1-service.rc"
DELETE_FROM_WORK_DIR "vendor" "etc/seccomp_policy/configstore@1.1.policy"
LOG_STEP_OUT

LOG_STEP_IN "- Adding FBE v2 support"
sed -i '\|/dev/block/bootdevice/by-name/userdata|c\
/dev/block/bootdevice/by-name/userdata                 /data                  f2fs    noatime,nosuid,nodev,discard,usrquota,grpquota,fsync_mode=nobarrier,reserve_root=32768,resgid=5678,inlinecrypt    latemount,wait,check,fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized,keydirectory=/metadata/vold/metadata_encryption,sysfs_path=/sys/devices/platform/soc/1d84000.ufshc,quota,reservedsize=128M,checkpoint=fs' \
"$WORK_DIR/vendor/etc/fstab.qcom"
LOG_STEP_OUT

LOG_STEP_IN "- Remove Samsung Encryption"
sed -i -E \
    's/^([^#].*?)fileencryption=[^,]*(.*)$/# &\n\1encryptable\2/' \
    "$WORK_DIR/vendor/etc/fstab.qcom"
sed -i -E \
    's/^([^#].*?)forceencrypt=[^,]*(.*)$/# &\n\1encryptable\2/' \
    "$WORK_DIR/vendor/etc/fstab.qcom"
LOG_STEP_OUT

LOG_STEP_IN "- Allowing mremap in vendor Codec2 seccomp policies"
C2_POLICY_FIRST=""
C2_POLICY_PATCHED=false
while IFS= read -r f; do
    [ -z "$C2_POLICY_FIRST" ] && C2_POLICY_FIRST="$f"
    if grep -q "^mremap:" "$f"; then
        sed -i 's/^mremap:.*/mremap: 1/' "$f"
        C2_POLICY_PATCHED=true
        LOG "- Relaxed mremap rule in $(basename "$f")"
    fi
done < <(find "$WORK_DIR/vendor/etc/seccomp_policy" -type f \( -iname "*c2*" -o -iname "*codec2*" \) 2> /dev/null)
if ! $C2_POLICY_PATCHED; then
    if [ -n "$C2_POLICY_FIRST" ]; then
        [ -n "$(tail -c1 "$C2_POLICY_FIRST")" ] && echo >> "$C2_POLICY_FIRST"
        echo "mremap: 1" >> "$C2_POLICY_FIRST"
        LOG "- Added mremap to $(basename "$C2_POLICY_FIRST")"
    else
        LOGW "No Codec2 seccomp policy found in vendor/etc/seccomp_policy"
    fi
fi
unset C2_POLICY_FIRST C2_POLICY_PATCHED
LOG_STEP_OUT

LOG_STEP_IN "- Removing 24-bit deep_buffer output (fixes no media sound on speaker)"
sed -i '/<mixPort name="deep_buffer"/,/<\/mixPort>/d' "$WORK_DIR/vendor/etc/audio_policy_configuration_base.xml"
sed -i 's/deep_buffer,//g' "$WORK_DIR/vendor/etc/audio_policy_configuration_base.xml"
LOG_STEP_OUT

# Multi-resolution SurfaceFlinger builds take the native panel density from
# ro.sf.init.lcd_density and fall back to 213 (tvdpi) when it is unset.
# FHD-only targets such as r8q never set it, so they report a 213 dpi
# (tablet-sized) display. Mirror ro.sf.lcd_density when it is missing.
LOG_STEP_IN "- Setting ro.sf.init.lcd_density"
LCD_DENSITY="$(GET_PROP "vendor" "ro.sf.lcd_density")"
[ "$LCD_DENSITY" ] || LCD_DENSITY="$(GET_PROP "odm" "ro.sf.lcd_density")"
if [ "$(GET_PROP "vendor" "ro.sf.init.lcd_density")" ] || [ "$(GET_PROP "odm" "ro.sf.init.lcd_density")" ]; then
    LOG "- ro.sf.init.lcd_density already set, skipping"
elif [ "$LCD_DENSITY" ]; then
    SET_PROP "vendor" "ro.sf.init.lcd_density" "$LCD_DENSITY"
else
    LOGW "- ro.sf.lcd_density not found, SurfaceFlinger will fall back to 213 dpi"
fi
unset LCD_DENSITY
LOG_STEP_OUT
