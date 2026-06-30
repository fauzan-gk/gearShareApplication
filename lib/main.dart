import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
<<<<<<< HEAD
=======
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/rental_request_screen.dart';
import 'screens/manage_requests_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/edit_item_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/rental_history_screen.dart';
import 'screens/browse_search_screen.dart';
import 'screens/category_screen.dart';
>>>>>>> dania

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
<<<<<<< HEAD
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const SplashScreen(), // temporary placeholder
=======

      // Starting screen
      home: const SplashScreen(),

      // Routes that take NO parameters
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/manage-requests': (context) => const ManageRequestsScreen(),
        '/add-item': (context) => const AddItemScreen(),
        '/my-listings': (context) => const MyListingsScreen(),
        '/rental-history': (context) => const RentalHistoryScreen(),
        '/browse-search': (context) => const BrowseSearchScreen(),
        '/category': (context) => const CategoryScreen(),
      },

      // Routes that NEED parameters passed in
      onGenerateRoute: (settings) {
        if (settings.name == '/item-detail') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => ItemDetailScreen(
              itemName: args['itemName']!,
              itemPrice: args['itemPrice']!,
            ),
          );
        }

        if (settings.name == '/rental-request') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => RentalRequestScreen(
              itemName: args['itemName']!,
              itemPrice: args['itemPrice']!,
            ),
          );
        }

        if (settings.name == '/edit-item') {
          // Adjust this once you confirm Dania's EditItemScreen constructor
          return MaterialPageRoute(
            builder: (context) => const EditItemScreen(),
          );
        }

        // Unknown route fallback
        return MaterialPageRoute(
          builder: (context) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
>>>>>>> dania
      },
    );
  }
}
