import 'package:flutter/material.dart';
import 'package:gearshare/screens/browse_search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GearShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF4820A)),
        useMaterial3: true,
      ),
      home: const BrowseSearchScreen(),
    );
  }
}
