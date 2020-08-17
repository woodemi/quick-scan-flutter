import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

const scanViewType = 'scan_view';

/// A web implementation of the QuickScan plugin.
class QuickScanWeb {
  static void registerWith(Registrar registrar) {
    ui.platformViewRegistry.registerViewFactory(
        scanViewType, (int viewId) => ScanViewWeb().videoElement);
  }
}

class ScanViewWeb {
  final VideoElement videoElement;

  ScanViewWeb() : videoElement = VideoElement() {
    // Access the webcam stream
    window.navigator.mediaDevices.getUserMedia(
      {
        'video': {'facingMode': 'environment'}
      },
    ).then((MediaStream stream) {
      videoElement.srcObject = stream;
      videoElement.setAttribute('playsinline', 'true');
      videoElement.play();
    });
  }
}
