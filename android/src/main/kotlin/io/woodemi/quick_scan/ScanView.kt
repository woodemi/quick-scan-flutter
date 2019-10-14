package io.woodemi.quick_scan

import android.content.Context
import android.util.Rational
import android.util.Size
import android.view.TextureView
import android.view.View
import androidx.camera.core.CameraX
import androidx.camera.core.Preview
import androidx.camera.core.PreviewConfig
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView

class ScanView(context: Context, messenger: BinaryMessenger, id: Int, params: Map<String, Any>?) : PlatformView, LifecycleOwner {
    private var rational: Rational
    private var size: Size
    private var preview: Preview
    private val textureView = TextureView(context)

    private val lifecycleRegistry: LifecycleRegistry

    init {
        rational = Rational(1, 1)
        size = Size(640, 640)
        preview = buildPreviewUseCase()

        lifecycleRegistry = LifecycleRegistry(this)
        CameraX.bindToLifecycle(this, preview)
    }

    override fun getView(): View {
        if (lifecycleRegistry.currentState < Lifecycle.State.RESUMED)
            lifecycleRegistry.markState(Lifecycle.State.RESUMED)
        return textureView
    }

    override fun dispose() {
        lifecycleRegistry.markState(Lifecycle.State.DESTROYED)
    }

    override fun getLifecycle(): Lifecycle = lifecycleRegistry

    private fun buildPreviewUseCase(): Preview {
        // Create configuration object for the viewfinder use case
        val previewConfig = PreviewConfig.Builder().apply {
            setTargetAspectRatio(rational)
            setTargetResolution(size)
        }.build()

        // Build the viewfinder use case
        val preview = Preview(previewConfig)

        // Every time the viewfinder is updated, recompute layout
        preview.setOnPreviewOutputUpdateListener {
            textureView.surfaceTexture = it.surfaceTexture
        }
        return preview
    }
}
