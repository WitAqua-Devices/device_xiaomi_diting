#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/xiaomi/diting',
    'device/xiaomi/sm8450-common',
    'hardware/qcom-caf/sm8450',
    'hardware/xiaomi',
    'vendor/qcom/opensource/commonsys-intf/display',
    'vendor/xiaomi/sm8450-common',
]


def lib_fixup_system_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'system' else None


lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    # Moved to /system, where a plain vendor.xiaomi.hardware.campostproc@1.0
    # would collide with the vendor copy this tree already ships.
    'vendor.xiaomi.hardware.campostproc@1.0': lib_fixup_system_suffix,
}

blob_fixups: blob_fixups_user_type = {
    # Both jni libraries want BnProducerListener::onBufferDetached(int), which
    # AOSP no longer has. The offset in getANativeWindow() is an android::Surface
    # vtable slot that moved with the platform, not with the device.
    'system/lib64/libcamera_algoup_jni.xiaomi.so': blob_fixup()
        .add_needed('libgui_shim_miuicamera.so')
        .sig_replace('08 AD 40 F9', '08 A9 40 F9'),
    'system/lib64/libcamera_mianode_jni.xiaomi.so': blob_fixup()
        .add_needed('libgui_shim_miuicamera.so'),
    # libhidltransport is gone
    'system/lib64/libmicampostproc_client.so': blob_fixup()
        .remove_needed('libhidltransport.so'),
    # MiuiCamera only takes its global path when ro.product.mod_device contains
    # "_global", which this tree never spells that way. See the patch.
    'product/priv-app/MiuiCamera/MiuiCamera.apk': blob_fixup().apktool_patch(
        'patches/MiuiCamera'
    ),
    (
        'vendor/etc/camera/diting_enhance_motiontuning.xml',
        'vendor/etc/camera/diting_motiontuning.xml',
    ): blob_fixup().regex_replace('xml=version', 'xml version'),
    'vendor/etc/camera/pureView_parameter.xml': blob_fixup().regex_replace(
        r'=([0-9]+)>', r'="\1">'
    ),
    (
        'vendor/bin/hw/vendor.qti.camera.provider@2.7-service_64',
        'vendor/lib64/camx.device@3.4-ext-impl.so',
        'vendor/lib64/camx.device@3.5-ext-impl.so',
        'vendor/lib64/camx.device@3.6-ext-impl.so',
        'vendor/lib64/camx.provider@2.4-external.so',
        'vendor/lib64/camx.provider@2.4-impl.so',
        'vendor/lib64/camx.provider@2.4-legacy.so',
        'vendor/lib64/camx.provider@2.5-external.so',
        'vendor/lib64/camx.provider@2.5-legacy.so',
        'vendor/lib64/camx.provider@2.6-legacy.so',
        'vendor/lib64/camx.provider@2.7-legacy.so',
        'vendor/lib64/com.qti.feature2.anchorsync.so',
    ): blob_fixup().replace_needed('libtinyxml2.so', 'libtinyxml2-v34.so'),
    (
        'vendor/lib64/hw/com.qti.chi.override.so',
        'vendor/lib64/libcamxcommonutils.so',
        'vendor/lib64/libmialgoengine.so',
    ): blob_fixup().add_needed('libprocessgroup_shim.so'),
    (
        'vendor/lib64/libalAILDC.so',
        'vendor/lib64/libalhLDC.so',
        'vendor/lib64/libalLDC.so',
        'vendor/lib64/libTrueSight.so',
    ): blob_fixup()
    .clear_symbol_version('AHardwareBuffer_allocate')
    .clear_symbol_version('AHardwareBuffer_describe')
    .clear_symbol_version('AHardwareBuffer_isSupported')
    .clear_symbol_version('AHardwareBuffer_lock')
    .clear_symbol_version('AHardwareBuffer_lockPlanes')
    .clear_symbol_version('AHardwareBuffer_release')
    .clear_symbol_version('AHardwareBuffer_unlock'),
    'vendor/lib64/libcamximageformatutils.so': blob_fixup().replace_needed(
        'vendor.qti.hardware.display.config-V2-ndk_platform.so',
        'vendor.qti.hardware.display.config-V2-ndk.so',
    ),
}

module = ExtractUtilsModule(
    'diting',
    'xiaomi',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
    add_firmware_proprietary_file=True,
)

if __name__ == '__main__':
    utils = ExtractUtils.device_with_common(
        module, 'sm8450-common', module.vendor
    )
    utils.run()
