import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const scanViewType = 'scan_view';

typedef void ScanResultCallback(String result);

class ScanView extends StatefulWidget {
  final ScanResultCallback callback;

  ScanView({this.callback});

  @override
  State<StatefulWidget> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  StreamSubscription scanResultSubscription;

  void onPlatformViewCreated(int id) {
    var stream = EventChannel('quick_scan/scanview_$id/event').receiveBroadcastStream();
    scanResultSubscription = stream.listen((result) {
      if (widget.callback != null)
        widget.callback(result);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scanResultSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return HtmlElementView(
        viewType: scanViewType,
      );
    } else if (Platform.isAndroid) {
      return AndroidView(
        viewType: scanViewType,
        onPlatformViewCreated: onPlatformViewCreated,
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: scanViewType,
        onPlatformViewCreated: onPlatformViewCreated,
      );
    }
    throw UnimplementedError('Unknown platform: ${Platform.operatingSystem}');
  }
}