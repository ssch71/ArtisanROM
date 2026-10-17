#!/system/bin/sh

LOG_TAG="RezossBootAnim"
MODULE_ROOT="/data/adb/modules"
MODULE_ZIP_REL="system/media/bootanimation.zip"
CACHE_DIR="/data/misc/bootanim"
CACHE_ZIP="$CACHE_DIR/rezoss.zip"
AOSP_BOOTANIM="/system/bin/bootanimation_zip"
WAIT_TIMEOUT=30
BOOTANIM_WAIT_TIMEOUT=60
MODE="apply"

case "$1" in
    ""|--apply)
        MODE="apply"
        ;;
esac

log_msg()
{
    log -t "$LOG_TAG" "$1"
}

is_boot_completed()
{
    [ "$(getprop sys.boot_completed 2>/dev/null)" = "1" ]
}

is_stock_bootanim_running()
{
    [ "$(getprop init.svc.bootanim 2>/dev/null)" = "running" ]
}

is_rezoss_bootanim_running()
{
    [ "$(getprop init.svc.rezoss_bootanim 2>/dev/null)" = "running" ]
}

find_module_zip_once()
{
    FOUND_ZIP=""

    [ -d "$MODULE_ROOT" ] || return 1

    for MODULE_DIR in "$MODULE_ROOT"/*; do
        [ -d "$MODULE_DIR" ] || continue
        [ -f "$MODULE_DIR/module.prop" ] || continue
        [ -f "$MODULE_DIR/disable" ] && continue
        [ -f "$MODULE_DIR/remove" ] && continue

        MODULE_ZIP="$MODULE_DIR/$MODULE_ZIP_REL"
        [ -s "$MODULE_ZIP" ] || continue

        FOUND_ZIP="$MODULE_ZIP"
        return 0
    done

    return 1
}

wait_for_module_zip()
{
    WAITED=0

    while [ "$WAITED" -le "$WAIT_TIMEOUT" ]; do
        if find_module_zip_once; then
            return 0
        fi

        if is_boot_completed; then
            return 1
        fi

        [ "$WAITED" -ge "$WAIT_TIMEOUT" ] && break

        sleep 1
        WAITED=$((WAITED + 1))
    done

    return 1
}

cache_module_zip()
{
    SRC_ZIP="$1"
    TMP_ZIP="$CACHE_ZIP.tmp.$$"

    if ! mkdir -p "$CACHE_DIR"; then
        log_msg "failed to create $CACHE_DIR"
        return 1
    fi

    rm -f "$TMP_ZIP" 2>/dev/null
    if ! cp "$SRC_ZIP" "$TMP_ZIP"; then
        log_msg "failed to copy $SRC_ZIP"
        rm -f "$TMP_ZIP" 2>/dev/null
        return 1
    fi

    chown system:system "$TMP_ZIP" 2>/dev/null || true
    chmod 0644 "$TMP_ZIP" 2>/dev/null || true
    restorecon "$TMP_ZIP" 2>/dev/null || true

    if ! mv -f "$TMP_ZIP" "$CACHE_ZIP"; then
        log_msg "failed to move cached bootanimation zip"
        rm -f "$TMP_ZIP" 2>/dev/null
        return 1
    fi

    restorecon "$CACHE_ZIP" 2>/dev/null || true
    log_msg "cached module bootanimation from $SRC_ZIP"
    return 0
}

clear_cached_zip()
{
    if [ -e "$CACHE_ZIP" ] && ! is_rezoss_bootanim_running; then
        rm -f "$CACHE_ZIP" 2>/dev/null
    fi
}

start_rezoss_bootanim()
{
    WAITED=0

    if [ ! -x "$AOSP_BOOTANIM" ]; then
        log_msg "$AOSP_BOOTANIM is missing"
        return 0
    fi

    if [ ! -s "$CACHE_ZIP" ]; then
        log_msg "$CACHE_ZIP is missing"
        return 0
    fi

    if is_rezoss_bootanim_running; then
        log_msg "rezoss_bootanim is already running"
        return 0
    fi

    while [ "$WAITED" -le "$BOOTANIM_WAIT_TIMEOUT" ]; do
        if is_rezoss_bootanim_running; then
            log_msg "rezoss_bootanim is already running"
            return 0
        fi

        if is_stock_bootanim_running; then
            setprop ctl.stop bootanim 2>/dev/null
            setprop ctl.start rezoss_bootanim 2>/dev/null
            log_msg "requested AOSP zip bootanimation service"
            return 0
        fi

        if is_boot_completed; then
            log_msg "boot completed before Samsung bootanim service was running"
            return 0
        fi

        [ "$WAITED" -ge "$BOOTANIM_WAIT_TIMEOUT" ] && break

        sleep 1
        WAITED=$((WAITED + 1))
    done

    log_msg "Samsung bootanim service was not running before timeout"
    return 0
}

apply_module_zip()
{
    if ! wait_for_module_zip; then
        clear_cached_zip
        log_msg "no module bootanimation.zip, keeping Samsung QMG bootanimation"
        return 0
    fi

    if ! cache_module_zip "$FOUND_ZIP"; then
        return 0
    fi

    start_rezoss_bootanim
    return 0
}

case "$MODE" in
    *)
        apply_module_zip
        ;;
esac

exit 0
