import 'dart:io';

import 'package:flutter/cupertino.dart';

const scanViewType = 'scan_view';

class QuickScanView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: scanViewType,
      );
    }
    throw UnimplementedError('Unknown platform: ${Platform.operatingSystem}');
  }
}