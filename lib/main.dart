import 'package:flutter/material.dart';
import 'package:gearshare/screens/add_item_screen.dart';
//import 'package:gearshare/screens/add_item_screen.dart';
//import 'package:gearshare/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddItemScreen(),
    );
  }
}
