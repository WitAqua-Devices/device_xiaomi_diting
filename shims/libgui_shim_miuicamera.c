/*
 * Copyright (C) 2026 The WitAqua Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * The xiaomi camera JNI libraries are built against a libgui that still has
 * BnProducerListener::onBufferDetached(int). AOSP dropped it, so both of them
 * fail to link at load time and MiuiCamera dies in System.loadLibrary.
 *
 * Nothing calls it on the paths these libraries take - the listener it belongs
 * to is only ever registered, never driven - so an empty body is enough to get
 * them loaded.
 */
void _ZN7android18BnProducerListener16onBufferDetachedEi() {
    return;
}
