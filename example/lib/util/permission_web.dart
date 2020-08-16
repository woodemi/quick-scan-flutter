import 'dart:html';

const permissionCamera = {'name': 'camera'};

const statusDenied = 'denied';
const statusGranted = 'granted';
const statusPrompt = 'prompt';

Future<void> checkAndRequestPermission() async {
  var permissionStatus =
      await window.navigator.permissions.query(permissionCamera);
  if (permissionStatus.state != statusGranted) {
    // FIXME
    // var status = await window.navigator.permissions.request(permissionCamera);
    var status = permissionStatus;
    if (status.state == statusDenied) {
      throw Exception('Permission Denied');
    }
  }
}
