#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from xiaomi sm8450-common
TARGET_HAS_UDFPS := true
$(call inherit-product, device/xiaomi/sm8450-common/common.mk)

# Inherit from the proprietary version
$(call inherit-product, vendor/xiaomi/diting/diting-vendor.mk)

# Audio
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/mixer_paths_waipio_mtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cape/mixer_paths_waipio_mtp.xml \
    $(LOCAL_PATH)/audio/resourcemanager_waipio_mtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cape/resourcemanager_waipio_mtp.xml \
    $(LOCAL_PATH)/audio/usecaseKvManager.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usecaseKvManager.xml

# MIUI Camera
#
# The apk and the xiaomi jni libraries come from vendor/xiaomi/diting; the apk
# is patched by extract-files.py (patches/MiuiCamera). What has to live here:
#
#  - the privileged permission allowlist, or PackageManager refuses the app the
#    8 privileged permissions it declares, which is fatal on an enforcing build
#  - the hidden api allowlist; MiuiCamera is built against MIUI's framework and
#    uses plenty of @hide, which Android would otherwise block
#  - public.libraries, so the two jni libraries can be loaded by name from the
#    app's classloader namespace
#  - the libgui shim the jni libraries are linked against by extract-files.py
PRODUCT_PACKAGES += \
    libgui_shim_miuicamera

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/privapp-permissions-miuicamera.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-miuicamera.xml \
    $(LOCAL_PATH)/configs/miuicamera-hiddenapi-package-allowlist.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/miuicamera-hiddenapi-package-allowlist.xml \
    $(LOCAL_PATH)/configs/public.libraries-xiaomi.txt:$(TARGET_COPY_OUT_SYSTEM)/etc/public.libraries-xiaomi.txt

# FeliCa (Osaifu-Keitai)
#
# The element is provisioned per handset and diting ships as two japanese
# models, so the configuration - and the NFC routing that goes with it - is
# picked by hand in FelicaParts and bound over the canonical paths from
# init.felica_model.rc. There is nothing to detect it with: both stock
# firmwares report the same sku and the same fastboot product, and the model
# number lives only in a /odm prop this ROM writes itself. See docs/felica.md.
PRODUCT_PACKAGES += \
    FelicaParts

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/system_ext/etc/init/init.felica_model.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.felica_model.rc

# MIUI Camera
#
# The apk and the xiaomi jni libraries come from vendor/xiaomi/diting; the apk
# is patched by extract-files.py (patches/MiuiCamera). What has to live here:
#
#  - the privileged permission allowlist, or PackageManager refuses the app the
#    8 privileged permissions it declares, which is fatal on an enforcing build
#  - the hidden api allowlist; MiuiCamera is built against MIUI's framework and
#    uses plenty of @hide, which Android would otherwise block
#  - public.libraries, so the two jni libraries can be loaded by name from the
#    app's classloader namespace
#  - the libgui shim the jni libraries are linked against by extract-files.py
PRODUCT_PACKAGES += \
    libgui_shim_miuicamera

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/privapp-permissions-miuicamera.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-miuicamera.xml \
    $(LOCAL_PATH)/configs/miuicamera-hiddenapi-package-allowlist.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/miuicamera-hiddenapi-package-allowlist.xml \
    $(LOCAL_PATH)/configs/public.libraries-xiaomi.txt:$(TARGET_COPY_OUT_SYSTEM)/etc/public.libraries-xiaomi.txt

# Overlay
PRODUCT_PACKAGES += \
    ApertureResDiting \
    FrameworksResDiting \
    NfcResDiting \
    SettingsProviderResDiting \
    SettingsProviderResDitingCN \
    SettingsResDiting \
    SystemUIResDiting \
    WifiResDiting \
    WifiResDitingCN

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# System properties
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/properties/build_CN.prop:$(TARGET_COPY_OUT_ODM)/etc/build_CN.prop \
    $(LOCAL_PATH)/properties/build_GL.prop:$(TARGET_COPY_OUT_ODM)/etc/build_GL.prop \
    $(LOCAL_PATH)/properties/build_JP.prop:$(TARGET_COPY_OUT_ODM)/etc/build_JP.prop

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/properties/build_CN.prop:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/odm/etc/build_CN.prop \
    $(LOCAL_PATH)/properties/build_GL.prop:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/odm/etc/build_GL.prop \
    $(LOCAL_PATH)/properties/build_JP.prop:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/odm/etc/build_JP.prop

# Vibrator
$(call soong_config_set,qti_vibrator,effect_lib,libqtivibratoreffect.xiaomi)
$(call soong_config_set_bool,qti_vibrator,use_effect_stream,true)
