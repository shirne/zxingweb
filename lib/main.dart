import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'ZXing Web Demo',
      theme: CupertinoThemeData(
        primaryColor: Colors.blue,
      ),
      home: IndexPage(),
    );
  }
}
