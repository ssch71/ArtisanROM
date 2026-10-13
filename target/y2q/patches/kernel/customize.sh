KERNEL_TAG="boot-y2q-20261014-013808"
KERNEL_REPO="https://github.com/ssch71/not_samsung.sm8250-4.19/releases/download/$KERNEL_TAG"

LOG_STEP_IN "- Downloading not_kernel ($KERNEL_TAG)"
mkdir -p "$WORK_DIR/kernel"
rm -f "$WORK_DIR/kernel/boot.img" "$WORK_DIR/kernel/dtbo.img" "$WORK_DIR/kernel/SHA256SUMS.txt"

DOWNLOAD_FILE "$KERNEL_REPO/boot.img" "$WORK_DIR/kernel/boot.img"
DOWNLOAD_FILE "$KERNEL_REPO/dtbo.img" "$WORK_DIR/kernel/dtbo.img"
DOWNLOAD_FILE "$KERNEL_REPO/SHA256SUMS.txt" "$WORK_DIR/kernel/SHA256SUMS.txt"

for IMG in boot.img dtbo.img; do
    WANT="$(grep -E "[ */]$IMG\$" "$WORK_DIR/kernel/SHA256SUMS.txt" | awk '{print $1}' | head -n 1)"
    GOT="$(sha256sum "$WORK_DIR/kernel/$IMG" | awk '{print $1}')"
    if [ -z "$WANT" ]; then
        LOGW "- $IMG not listed in SHA256SUMS.txt, skipping check"
    elif [ "$WANT" != "$GOT" ]; then
        ABORT "$IMG checksum mismatch ($KERNEL_TAG)"
    else
        LOG "- $IMG checksum OK"
    fi
done
rm -f "$WORK_DIR/kernel/SHA256SUMS.txt"

unset KERNEL_TAG KERNEL_REPO IMG WANT GOT
LOG_STEP_OUT
