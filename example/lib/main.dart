import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_scan/quick_scan.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final permissionHandler = PermissionHandler();

class _MyAppState extends State<MyApp> {
  bool permitted = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            FlatButton(
              child: Text('Scan'),
              onPressed: () async {
                try {
                  await checkAndRequestPermission();
                  setState(() => permitted = true);
                } catch (e) {
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
            ),
          ],
        ),
        body: buildBody(),
      ),
    );
  }

  Future<void> checkAndRequestPermission() async {
    var permissionStatus = await permissionHandler.checkPermissionStatus(PermissionGroup.camera);
    if (permissionStatus != PermissionStatus.granted) {
      var resultMap = await permissionHandler.requestPermissions([PermissionGroup.camera]);
      if (resultMap[PermissionGroup.camera] != PermissionStatus.granted) {
        throw Exception('Permission Denied');
      }
    }
  }

  Widget buildBody() {
    if (!permitted)
      return Container();

    return ScanView(
      callback: (String result) {
        print('scanResult $result');
      },
    );
  }
}
