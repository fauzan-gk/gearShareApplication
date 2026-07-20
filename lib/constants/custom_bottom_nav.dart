import 'package:flutter/material.dart';
import 'app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  // Route names in the SAME ORDER as the nav items below.
  // Index 4 (Profile) added — matches the reference ProfileScreen design.
  static const List<String> _routes = [
    '/home',
    '/browse-search',
    '/add-item',
    '/my-listings',
    '/profile',
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return; // already on this tab, do nothing
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType
            .fixed, // keeps all labels visible with 5 items
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHintFor(context),
        backgroundColor: AppColors.surfaceFor(context),
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: "Browse",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: "Listings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
