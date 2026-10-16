# ACodec::reconfigEncoder4OtherApps() reads /proc/<pid>/cmdline with
# fread(buf, 1, 512, fp) into a 255 byte buffer. Android 16 libstagefright is
# built with FORTIFY, so every OMX encoder on the legacy SM8250 vendor (the
# screen recorder's OMX.qcom.video.encoder.avc) aborts with SIGABRT.
# mov w2, #0x200 -> mov w2, #0xfe (read at most 254 bytes)
HEX_PATCH "$WORK_DIR/system/system/lib64/libstagefright.so" \
    "02408052e30315aae41f8052" \
    "c21f8052e30315aae41f8052"
