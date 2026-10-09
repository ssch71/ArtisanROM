# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# UN1CA configuration file for Qualcomm devices (qssi)

# Galaxy S24+ (Snapdragon 8 Gen 3 for Galaxy / SM8650-AC) (One UI 8.5)
# Keep the tested release pinned so framework/display behaviour is
# reproducible instead of silently moving with monthly FUS updates.
# TODO: fill in the real model/CSC/IMEI. SM-S926U1/XAA is the unlocked US model,
#       SM-S926W/BMC is Canada, SM-S926U is carrier-locked.
SOURCE_FIRMWARE="SM-S926U/XAU/350822573779116"

SOURCE_EXTRA_FIRMWARES=()
SOURCE_PLATFORM_SDK_VERSION=36
# Snapdragon S24+ launched with Android 14 (API 34).
SOURCE_PRODUCT_SHIPPING_API_LEVEL=34
SOURCE_BOARD_API_LEVEL=34
# Qualcomm devices use the QTI dynamic partition group, not group_basic.
SOURCE_SUPER_GROUP_NAME="qti_dynamic_partitions"
# The Android 16 display stack (dynamic resolution and native
# 24/10/30/48/60/80/120-Hz policy) is the same panel/framework as the Exynos
# S24+. Do not apply y2s resolution/HFR compatibility patches on top of it.
SOURCE_USE_NATIVE_DISPLAY_STACK=true
# Current Android 16 Settings/SystemUI use the generic fingerprint feature
# gates and already support optical UDFPS.  Only the legacy HIDL/framework
# sensor mapping still needs conversion when the target is optical.
SOURCE_USE_NATIVE_FINGERPRINT_UI=true
# The current services.jar gates the hardware mDNIe paths through A11yRune.
# Its classes were redesigned, so the old control-flow transplant must not be
# applied after the framework flags have already disabled those paths.
SOURCE_USE_MODERN_MDNIE_SERVICE=true

# SEC Product Feature
SOURCE_AUDIO_CONFIG_RECORDALIVE_LIB_VERSION="08020"
SOURCE_AUDIO_SUPPORT_ACH_RINGTONE=true
SOURCE_AUDIO_SUPPORT_DUAL_SPEAKER=true
SOURCE_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND=true
SOURCE_BLUETOOTH_SUPPORT_A2DPSINK_PROFILE=true
SOURCE_BLUETOOTH_SUPPORT_A2DP_SBM=false
SOURCE_BLUETOOTH_SUPPORT_HEAD_SAR_BACKOFF=false
SOURCE_BLUETOOTH_SUPPORT_XLNA_CONTROL=false
SOURCE_CAMERA_SUPPORT_CAMERAX_EXTENSION=true
SOURCE_CAMERA_SUPPORT_CUTOUT_PROTECTION=false
SOURCE_CAMERA_SUPPORT_MASS_APP_FLAVOR=false
SOURCE_CAMERA_SUPPORT_SDK_SERVICE=true
SOURCE_COMMON_CONFIG_MDNIE_MODE="65303"
SOURCE_COMMON_SUPPORT_DYN_RESOLUTION_CONTROL=true
SOURCE_COMMON_SUPPORT_EMBEDDED_SIM=true
SOURCE_COMMON_SUPPORT_HDR_EFFECT=true
SOURCE_DVFSAPP_CONFIG_DVFS_POLICY_FILENAME="dvfs_policy_default"
# TODO: verify against the source's floating_feature.xml (SM8650 policy name)
SOURCE_DVFSAPP_CONFIG_SSRM_POLICY_FILENAME="siop_e2q_sm8650"
SOURCE_FINGERPRINT_CONFIG_SENSOR="google_touch_display_ultrasonic"
SOURCE_LCD_CONFIG_COLOR_WEAKNESS_SOLUTION="3"
SOURCE_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS="5"
SOURCE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE="120"
SOURCE_LCD_CONFIG_HFR_MODE="3"
SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE="24,10,30,48,60,80,120"
SOURCE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE_NS="none"
SOURCE_LCD_CONFIG_SEAMLESS_BRT="none"
SOURCE_LCD_CONFIG_SEAMLESS_LUX="none"
SOURCE_LCD_SUPPORT_MDNIE_HW=true
# TODO: verify eSE vendor/COS on the Snapdragon model (differs from the Exynos one)
SOURCE_SECURITY_CONFIG_ESE_CHIP_VENDOR="GEMALTO"
SOURCE_SECURITY_CONFIG_ESE_COS_NAME="UT8.2U"
# TODO: verify TelephonyFeatures in the US/CA framework; the Exynos EUX value
#       (entitlement_sa) does not necessarily carry over.
SOURCE_RIL_FEATURES="onebinary entitlement_sa"
SOURCE_RIL_SIM_CONFIG_MULTISIM_TRAYCOUNT="2"
SOURCE_RIL_SUPPORT_WATERPROOF_SIM_TRAY_MSG=true
# TODO: verify SemWifiInjector literal on the Snapdragon firmware (Exynos was 2)
SOURCE_WLAN_CONFIG_CONNECTION_PERSONALIZATION="2"
# TODO: the CPU C-state / L1SS / affinity values below are Exynos tuned;
#       replace them with what the Snapdragon floating_feature.xml reports.
SOURCE_WLAN_CONFIG_CPU_CSTATE_DISABLE_THRESHOLD="100"
SOURCE_WLAN_CONFIG_CUSTOM_BACKOFF="none"
SOURCE_WLAN_CONFIG_DATA_ACTIVITY_AFFINITY_BOOSTER_THRESHOLD="0"
SOURCE_WLAN_CONFIG_DYNAMIC_SWITCH="0"
SOURCE_WLAN_CONFIG_L1SS_DISABLE_THRESHOLD="0"
SOURCE_WLAN_SUPPORT_80211AX=true
# Snapdragon S24+ (WCN7851, Wi-Fi 7) in the US/CA models supports 6 GHz.
SOURCE_WLAN_SUPPORT_80211AX_6GHZ=true
SOURCE_WLAN_SUPPORT_APE_SERVICE=true
SOURCE_WLAN_SUPPORT_LOWLATENCY=true
SOURCE_WLAN_SUPPORT_MBO=true
SOURCE_WLAN_SUPPORT_MIMO=true
SOURCE_WLAN_SUPPORT_MOBILEAP_11AX=true
SOURCE_WLAN_SUPPORT_MOBILEAP_5G_BASEDON_COUNTRY=false
SOURCE_WLAN_SUPPORT_MOBILEAP_6G=true
SOURCE_WLAN_SUPPORT_MOBILEAP_DUALAP=true
SOURCE_WLAN_SUPPORT_MOBILEAP_OWE=true
SOURCE_WLAN_SUPPORT_MOBILEAP_POWER_SAVEMODE=true
SOURCE_WLAN_SUPPORT_MOBILEAP_PRIORITIZE_TRAFFIC=true
SOURCE_WLAN_SUPPORT_MOBILEAP_WIFI_CONCURRENCY=true
SOURCE_WLAN_SUPPORT_MOBILEAP_WIFISHARING_LITE=false
SOURCE_WLAN_SUPPORT_SWITCH_FOR_INDIVIDUAL_APPS=true
# TODO: verify TWT. The Exynos S926B WifiDriverFeatureProvider had it disabled;
#       the Qualcomm Wi-Fi driver may expose it.
SOURCE_WLAN_SUPPORT_TWT_CONTROL=false
SOURCE_WLAN_SUPPORT_WIFI_TO_CELLULAR=true
