import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/supabase_config.dart';
import 'providers/theme_provider.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const GearShareApp(),
    ),
  );
}

class GearShareApp extends StatelessWidget {
  const GearShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'GearShare',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkNavy,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/login':
            page = const LoginScreen();
            break;
          case '/register':
            page = const RegisterScreen();
            break;
          case '/forgot-password':
            page = const ForgotPasswordScreen();
            break;
          case '/home':
            page = const HomeScreen();
            break;
          case '/manage-requests':
            page = const ManageRequestsScreen();
            break;
          case '/add-item':
            page = const AddItemScreen();
            break;
          case '/my-listings':
            page = const MyListingsScreen();
            break;
          case '/rental-history':
            page = const RentalHistoryScreen();
            break;
          case '/browse-search':
            page = const BrowseSearchScreen();
            break;
          case '/category':
            page = const CategoryScreen();
            break;
          case '/profile':
            page = const ProfileScreen();
            break;
          case '/edit-profile':
            page = const EditProfileScreen();
            break;
          case '/ratings':
            page = const RatingsScreen();
            break;
          case '/settings':
            page = const SettingsScreen();
            break;
          case '/item-detail': {
            final args = settings.arguments as Map<String, String>;
            page = ItemDetailScreen(listingId: args['listingId']!);
            break;
          }
          case '/rental-request': {
            final args = settings.arguments as Map<String, String>;
            page = RentalRequestScreen(
              itemName: args['itemName']!,
              itemPrice: args['itemPrice']!,
              ownerId: args['ownerId'] ?? '',
            );
            break;
          }
          case '/edit-item': {
            final args = settings.arguments as Map<String, String>;
            page = EditItemScreen(listingId: args['listingId']!);
            break;
          }
          default:
            page = const Scaffold(
              body: Center(child: Text('Page not found')),
            );
        }
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            const begin = Offset(0.0, 0.03);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
