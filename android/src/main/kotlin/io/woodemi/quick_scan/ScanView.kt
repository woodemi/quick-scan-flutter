package io.woodemi.quick_scan

import android.content.Context
import android.view.TextureView
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView

class ScanView(context: Context, messenger: BinaryMessenger, id: Int, params: Map<String, Any>?) : PlatformView {
    private val textureView = TextureView(context)

    override fun getView(): View = textureView

    override fun dispose() {
        // TODO
    }
}
