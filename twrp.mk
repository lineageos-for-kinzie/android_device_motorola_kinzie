PRODUCT_COPY_FILES += device/motorola/kinzie/recovery/twrp.fstab:recovery/root/etc/twrp.fstab

RECOVERY_VARIANT := twrp
# BOARD_HAS_FLIPPED_SCREEN := true
TW_THEME := portrait_hdpi
TW_NEW_ION_HEAP := true
TW_INCLUDE_CRYPTO := true
TW_NO_SCREEN_BLANK := true
TW_BRIGHTNESS_PATH := /sys/class/leds/lcd-backlight/brightness
TARGET_RECOVERY_PIXEL_FORMAT := RGBA_8888
BOARD_SUPPRESS_SECURE_ERASE := true
RECOVERY_GRAPHICS_USE_LINELENGTH := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TW_EXTRA_LANGUAGES := true
# TARGET_CRYPTFS_HW_PATH += vendor/qcom/opensource/cryptfs_hw
