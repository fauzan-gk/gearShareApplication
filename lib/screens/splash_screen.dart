import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait 3 seconds then go to login screen
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2A4A), // Dark Navy
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon placeholder
            Container(
              width: 100,

              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF4820A), // Orange
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.handshake, color: Colors.white, size: 60),
            ),

            const SizedBox(height: 24),

            // App Name
            const Text(
              'Gear',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Share',
              style: TextStyle(
                color: Color(0xFFF4820A),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Rent. Lend. Repeat.',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),

            const SizedBox(height: 60),

            // Loading indicator
            const CircularProgressIndicator(color: Color(0xFFF4820A)),
          ],
        ),
      ),
    );
  }
}
