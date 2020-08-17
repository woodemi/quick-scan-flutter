import 'package:flutter/material.dart';
import 'package:quick_scan/quick_scan.dart';

import 'util/permission.dart' if (dart.library.html) 'util/permission_web.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool permitted = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            _buildFlatButton(),
          ],
        ),
        body: buildBody(),
      ),
    );
  }

  Widget _buildFlatButton() {
    return Builder(
      builder: (context) {
        return FlatButton(
          child: Text('Scan'),
          onPressed: () async {
            try {
              await checkAndRequestPermission();
              setState(() => permitted = true);
            } catch (e) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
        );
      },
    );
  }

  Widget buildBody() {
    if (!permitted) return Container();

    return ScanView(
      callback: (String result) {
        print('scanResult $result');
      },
    );
  }
}
