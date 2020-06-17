package io.woodemi.quick_scan

import android.content.Context
import android.graphics.ImageFormat
import android.util.Size
import android.view.View
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView
import java.nio.ByteBuffer
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

class ScanView(context: Context, messenger: BinaryMessenger, id: Int, params: Map<String, Any>?) : PlatformView, EventChannel.StreamHandler, LifecycleOwner {
    private var scanResultSink: EventChannel.EventSink? = null

    private var size: Size
    private val viewFinder = PreviewView(context)

    private val lifecycleRegistry: LifecycleRegistry

    init {
        EventChannel(messenger, "quick_scan/scanview_$id/event").setStreamHandler(this)

        size = Size(640, 640)

        lifecycleRegistry = LifecycleRegistry(this)

        val cameraProviderFuture = ProcessCameraProvider.getInstance(viewFinder.context)
        cameraProviderFuture.addListener(Runnable {
            val targetAspectRatio = aspectRatio(size.width, size.height)
            val rotation = viewFinder.display.rotation

            val preview = buildPreviewUseCase(targetAspectRatio, rotation)
            val imageAnalysis = buildImageAnalysisUseCase(targetAspectRatio, rotation)

            val cameraSelector = CameraSelector.Builder().requireLensFacing(CameraSelector.LENS_FACING_BACK).build()
            cameraProviderFuture.get().bindToLifecycle(this, cameraSelector, preview, imageAnalysis)
        }, ContextCompat.getMainExecutor(context))
    }

    /** Blocking camera operations are performed using this executor */
    private lateinit var cameraExecutor: ExecutorService

    override fun getView(): View {
        if (lifecycleRegistry.currentState < Lifecycle.State.RESUMED) {
            lifecycleRegistry.currentState = Lifecycle.State.RESUMED
            // Initialize our background executor
            cameraExecutor = Executors.newSingleThreadExecutor()
        }
        return viewFinder
    }

    override fun dispose() {
        lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
        cameraExecutor.shutdown()
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        scanResultSink = eventSink
    }

    override fun onCancel(arguments: Any?) {
        scanResultSink = null
    }

    override fun getLifecycle(): Lifecycle = lifecycleRegistry

    private fun buildPreviewUseCase(aspectRatio: Int, rotation: Int): Preview {
        // Build the viewfinder use case
        val preview = Preview.Builder()
                // We request aspect ratio but no resolution
                .setTargetAspectRatio(aspectRatio)
                // Set initial target rotation
                .setTargetRotation(rotation)
                .build()

        // Attach the viewfinder's surface provider to preview use case
        preview.setSurfaceProvider(viewFinder.createSurfaceProvider())
        return preview
    }

    private fun buildImageAnalysisUseCase(aspectRatio: Int, rotation: Int): ImageAnalysis {
        val imageAnalyzer = ImageAnalysis.Builder()
                // We request aspect ratio but no resolution
                .setTargetAspectRatio(aspectRatio)
                // Set initial target rotation, we will have to call this again if rotation changes
                // during the lifecycle of this use case
                .setTargetRotation(rotation)
                .build()

        // Build the image analysis use case and instantiate our analyzer
        imageAnalyzer.setAnalyzer(cameraExecutor, QRCodeAnalyzer())
        return imageAnalyzer
    }

    private inner class QRCodeAnalyzer : ImageAnalysis.Analyzer {
        private val reader = MultiFormatReader().apply {
            setHints(mapOf(DecodeHintType.POSSIBLE_FORMATS to listOf(BarcodeFormat.QR_CODE)))
        }

        override fun analyze(image: ImageProxy) {
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
                viewFinder.post { scanResultSink?.success(result.text) }
            } catch (e: NotFoundException) {
                // Empty
            }

            image.close()
        }

        private fun ByteBuffer.toByteArray(): ByteArray {
            rewind()    // Rewind the buffer to zero
            val data = ByteArray(remaining())
            get(data)   // Copy the buffer into a byte array
            return data // Return the byte array
        }
    }
}

private const val RATIO_4_3_VALUE = 4.0 / 3.0
private const val RATIO_16_9_VALUE = 16.0 / 9.0

/**
 *  [androidx.camera.core.ImageAnalysisConfig] requires enum value of
 *  [androidx.camera.core.AspectRatio]. Currently it has values of 4:3 & 16:9.
 *
 *  Detecting the most suitable ratio for dimensions provided in @params by counting absolute
 *  of preview ratio to one of the provided values.
 *
 *  @param width - preview width
 *  @param height - preview height
 *  @return suitable aspect ratio
 */
private fun aspectRatio(width: Int, height: Int): Int {
    val previewRatio = max(width, height).toDouble() / min(width, height)
    if (abs(previewRatio - RATIO_4_3_VALUE) <= abs(previewRatio - RATIO_16_9_VALUE)) {
        return AspectRatio.RATIO_4_3
    }
    return AspectRatio.RATIO_16_9
}