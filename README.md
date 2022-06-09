# DEPRECATED

This repo is deprecated; please use the new mono repo https://github.com/woodemi/quick.flutter

# quick_scan

A flutter plugin for scanning QR codes, as quick as adding a `Widget`

## Getting Started

*CAUTION: Check permission by yourself*

```dart
Widget build(BuildContext context) {
  return ScanView(
    callback: (String result) {
      print('scanResult $result');
    },
  );
}
```

## Setup

### iOS

Opt-in to the embedded views preview by adding a boolean property to the app's `Info.plist` file with the key `io.flutter.embedded_views_preview` and the value `YES`.
