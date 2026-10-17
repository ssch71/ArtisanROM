#!/system/bin/sh

PKG="com.google.android.mosey"
TAG="RezossMoseyPerms"

if ! pm path "$PKG" >/dev/null 2>&1; then
    log -t "$TAG" "$PKG is not installed; skipping permission fallback"
    exit 0
fi

pm grant "$PKG" android.permission.ACCESS_COARSE_LOCATION >/dev/null 2>&1
pm grant "$PKG" android.permission.ACCESS_FINE_LOCATION >/dev/null 2>&1
pm grant "$PKG" android.permission.NEARBY_WIFI_DEVICES >/dev/null 2>&1
pm grant "$PKG" android.permission.BLUETOOTH_SCAN >/dev/null 2>&1
pm grant "$PKG" android.permission.BLUETOOTH_ADVERTISE >/dev/null 2>&1
pm grant "$PKG" android.permission.ACCESS_MEDIA_LOCATION >/dev/null 2>&1
pm grant "$PKG" android.permission.ACCESS_BACKGROUND_LOCATION >/dev/null 2>&1

cmd appops set "$PKG" COARSE_LOCATION allow >/dev/null 2>&1
cmd appops set "$PKG" FINE_LOCATION allow >/dev/null 2>&1
cmd appops set "$PKG" NEARBY_WIFI_DEVICES allow >/dev/null 2>&1
cmd appops set "$PKG" BLUETOOTH_SCAN allow >/dev/null 2>&1
cmd appops set "$PKG" BLUETOOTH_ADVERTISE allow >/dev/null 2>&1
cmd appops set "$PKG" ACCESS_MEDIA_LOCATION allow >/dev/null 2>&1

log -t "$TAG" "ensured runtime grants and appops for $PKG"
