import 'package:flutter/material.dart';
// import 'screens/profile_screen.dart';
// import 'screens/edit_profile_screen.dart';
//import 'screens/ratings_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const GearShareApp());
}

class GearShareApp extends StatelessWidget {
  const GearShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      // Change this line only
      // home: ProfileScreen(),
      // home: EditProfileScreen(),
      // home: RatingsScreen(),
      home: SettingsScreen(),
    );
  }
}
