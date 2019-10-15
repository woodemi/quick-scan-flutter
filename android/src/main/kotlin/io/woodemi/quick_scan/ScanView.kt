package io.woodemi.quick_scan

import android.content.Context
import android.graphics.ImageFormat
import android.os.Handler
import android.os.HandlerThread
import android.util.Rational
import android.util.Size
import android.view.TextureView
import android.view.View
import androidx.camera.core.*
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView
import java.nio.ByteBuffer

class ScanView(context: Context, messenger: BinaryMessenger, id: Int, params: Map<String, Any>?) : PlatformView, EventChannel.StreamHandler, LifecycleOwner {
    private var scanResultSink: EventChannel.EventSink? = null

    private var rational: Rational
    private var size: Size
    private val textureView = TextureView(context)

    private val lifecycleRegistry: LifecycleRegistry

    init {
        EventChannel(messenger, "quick_scan/scanview_$id/event").setStreamHandler(this)

        rational = Rational(1, 1)
        size = Size(640, 640)
        val preview = buildPreviewUseCase()
        val imageAnalysis = buildImageAnalysisUseCase()

        lifecycleRegistry = LifecycleRegistry(this)
        CameraX.bindToLifecycle(this, preview, imageAnalysis)
    }

    override fun getView(): View {
        if (lifecycleRegistry.currentState < Lifecycle.State.RESUMED)
            lifecycleRegistry.markState(Lifecycle.State.RESUMED)
        return textureView
    }

    override fun dispose() {
        lifecycleRegistry.markState(Lifecycle.State.DESTROYED)
        CameraX.unbindAll()
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        scanResultSink = eventSink
    }

    override fun onCancel(arguments: Any?) {
        scanResultSink = null
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

    private fun buildImageAnalysisUseCase(): ImageAnalysis {
        // Setup image analysis pipeline that computes average pixel luminance
        val analyzerConfig = ImageAnalysisConfig.Builder().apply {
            // Use a worker thread for image analysis to prevent glitches
            val analyzerThread = HandlerThread(
                    "QRCodeAnalyzer"
            ).apply { start() }
            setCallbackHandler(Handler(analyzerThread.looper))
            // In our analysis, we care more about the latest image than
            // analyzing *every* image
            setImageReaderMode(ImageAnalysis.ImageReaderMode.ACQUIRE_LATEST_IMAGE)
        }.build()

        // Build the image analysis use case and instantiate our analyzer
        val analyzerUseCase = ImageAnalysis(analyzerConfig).apply {
            analyzer = QRCodeAnalyzer()
        }
        return analyzerUseCase
    }

    private inner class QRCodeAnalyzer : ImageAnalysis.Analyzer {
        private val reader = MultiFormatReader().apply {
            setHints(mapOf(DecodeHintType.POSSIBLE_FORMATS to listOf(BarcodeFormat.QR_CODE)))
        }

        override fun analyze(image: ImageProxy, rotationDegrees: Int) {
            if (image.format != ImageFormat.YUV_420_888) {
                println("Unsupported format: ${image.format}")
                return
            }

            val bytes = image.planes[0].buffer.toByteArray()
            val luminanceSource = PlanarYUVLuminanceSource(
                    bytes,
                    image.width,
                    image.height,
                    0,
                    0,
                    image.width,
                    image.height,
                    false
            )
            val binaryBitmap = BinaryBitmap(HybridBinarizer(luminanceSource))

            try {
                val result = reader.decode(binaryBitmap)
                textureView.post { scanResultSink?.success(result.text) }
            } catch (e: NotFoundException) {
                // Empty
            }
        }

        private fun ByteBuffer.toByteArray(): ByteArray {
            rewind()    // Rewind the buffer to zero
            val data = ByteArray(remaining())
            get(data)   // Copy the buffer into a byte array
            return data // Return the byte array
        }
    }
}
