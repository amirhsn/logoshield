import 'package:flutter/material.dart';
import 'package:logoshield/pages/resultPage.dart';
import 'package:logoshield/pages/scanPage.dart';
import 'package:logoshield/pages/splashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScanPage(),
    );
  }
}


