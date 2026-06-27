import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

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
        primaryColor: const Color(0xFF1B2A4A),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF4820A)),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const SplashScreen(), // temporary placeholder
      },
    );
  }
}
