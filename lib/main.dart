import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
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
import 'constants/app_colors.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/ratings_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const GearShareApp());
}

class GearShareApp extends StatelessWidget {
  const GearShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GearShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Blue is now the seed/primary color of the whole app's color scheme.
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),

      home: const SplashScreen(),

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
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/ratings': (context) => const RatingsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },

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
          return MaterialPageRoute(
            builder: (context) => const EditItemScreen(),
          );
        }

        return MaterialPageRoute(
          builder: (context) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
      },
    );
  }
}
