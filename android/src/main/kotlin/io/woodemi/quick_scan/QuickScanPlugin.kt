package io.woodemi.quick_scan

import io.flutter.plugin.common.PluginRegistry.Registrar

class QuickScanPlugin {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val scanViewFactory = ScanViewFactory(registrar.messenger())
            registrar.platformViewRegistry().registerViewFactory("scan_view", scanViewFactory)
        }
    }
}
