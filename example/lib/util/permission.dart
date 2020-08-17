import 'package:permission_handler/permission_handler.dart';

final permissionHandler = PermissionHandler();

Future<void> checkAndRequestPermission() async {
  var permissionStatus =
      await permissionHandler.checkPermissionStatus(PermissionGroup.camera);
  if (permissionStatus != PermissionStatus.granted) {
    var resultMap =
        await permissionHandler.requestPermissions([PermissionGroup.camera]);
    if (resultMap[PermissionGroup.camera] != PermissionStatus.granted) {
      throw Exception('Permission Denied');
    }
  }
}
