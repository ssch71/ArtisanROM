# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# Overlays
SYSTEM_DEBLOAT+="
system/app/WifiRROverlayAppH2E
system/app/WifiRROverlayAppQC
system/app/WifiRROverlayAppWifiLock
"
PRODUCT_DEBLOAT+="
overlay/SoftapOverlay6GHz
overlay/SoftapOverlayDualAp
overlay/SoftapOverlayOWE
"

# mAFPC
SYSTEM_DEBLOAT+="
system/bin/mafpc_write
"

# Auto Blocker
SYSTEM_DEBLOAT+="
system/app/Rampart
"

# Google
PRODUCT_DEBLOAT+="
priv-app/Velvet
"

# GameDriver
SYSTEM_DEBLOAT+="
system/priv-app/GameDriver-SM8650
"

# system_ext clean-up
SYSTEM_DEBLOAT+="
system/etc/permissions/org.carconnectivity.android.digitalkey.rangingintent.xml
system/etc/permissions/org.carconnectivity.android.digitalkey.secureelement.xml
"
SYSTEM_EXT_DEBLOAT+="
app/QCC
bin/qccsyshal@1.2-service
etc/init/vendor.qti.hardware.qccsyshal@1.2-service.rc
etc/permissions/com.qti.location.sdk.xml
etc/permissions/com.qualcomm.location.xml
etc/permissions/privapp-permissions-com.qualcomm.location.xml
framework/com.qti.location.sdk.jar
framework/org.carconnectivity.android.digitalkey.rangingintent.jar
framework/org.carconnectivity.android.digitalkey.secureelement.jar
lib/libqcc.so
lib/libqccdme.so
lib/libqccfileservice.so
lib/vendor.qti.hardware.qccsyshal@1.0.so
lib/vendor.qti.hardware.qccsyshal@1.1.so
lib/vendor.qti.hardware.qccsyshal@1.2.so
lib/vendor.qti.hardware.qccvndhal@1.0.so
lib/vendor.qti.hardware.trustedui@1.1.so
lib/vendor.qti.hardware.trustedui@1.2.so
lib/vendor.qti.qccvndhal_aidl-V1-ndk.so
lib64/libqcc.so
lib64/libqccdme.so
lib64/libqccfileservice.so
lib64/vendor.qti.hardware.qccsyshal@1.0.so
lib64/vendor.qti.hardware.qccsyshal@1.1.so
lib64/vendor.qti.hardware.qccsyshal@1.2-halimpl.so
lib64/vendor.qti.hardware.qccsyshal@1.2.so
lib64/vendor.qti.hardware.qccvndhal@1.0.so
lib64/vendor.qti.hardware.trustedui@1.1.so
lib64/vendor.qti.hardware.trustedui@1.2.so
lib64/vendor.qti.qccvndhal_aidl-V1-ndk.so
priv-app/com.qualcomm.location
priv-app/com.qualcomm.qti.services.systemhelper
"

SYSTEM_DEBLOAT+="
system/etc/default-permissions/default-permissions-com.samsung.android.service.aircommand.xml
system/etc/permissions/privapp-permissions-com.samsung.android.app.readingglass.xml
system/etc/permissions/privapp-permissions-com.samsung.android.service.aircommand.xml
system/etc/permissions/privapp-permissions-com.samsung.android.service.airviewdictionary.xml
system/etc/sysconfig/airviewdictionaryservice.xml
system/media/audio/pensounds
"

