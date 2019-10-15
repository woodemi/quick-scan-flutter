package io.woodemi.quick_scan

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ScanViewFactory(val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, creationParams: Any?): PlatformView {
        return ScanView(context, messenger, id, creationParams as? Map<String, Any>?)
    }
}

