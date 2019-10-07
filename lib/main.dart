import 'package:flutter/material.dart';
import 'package:ble_discoverer/pages/home_page.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Testing Bed',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Bluetooth Devices'),
    );
  }
}
