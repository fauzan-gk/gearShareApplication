import 'package:flutter/material.dart';
import 'app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  static const List<String> _routes = [
    '/home',
    '/browse-search',
    '/add-item',
    '/my-listings',
    '/profile',
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHintFor(context),
        backgroundColor: AppColors.surfaceFor(context),
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        items: List.generate(5, (index) {
          final isSelected = index == currentIndex;
          late IconData icon;
          late String label;
          switch (index) {
            case 0: icon = Icons.home_outlined; label = 'Home'; break;
            case 1: icon = Icons.grid_view_outlined; label = 'Browse'; break;
            case 2: icon = Icons.add_circle_outline; label = 'Add'; break;
            case 3: icon = Icons.list_alt_outlined; label = 'Listings'; break;
            case 4: icon = Icons.person_outline; label = 'Profile'; break;
          }
          return BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isSelected ? 8 : 0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: isSelected ? 26 : 24),
            ),
            label: label,
          );
        }),
      ),
    );
  }
}
