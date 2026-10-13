# Skip NandswapManager init in StorageManagerService (H_SYSTEM_READY).
# On this 4.19 kernel it stalls the StorageManagerService handler thread,
# so emulated;0 is never mounted at boot.
SMALI_PATCH "system" "system/framework/services.jar" \
    'smali/com/android/server/StorageManagerService$Callbacks.smali' "replace" \
    'handleMessage(Landroid/os/Message;)V' \
    'const-string v0, "Initialize NandswapManager..."' \
    '    goto :goto_19'
