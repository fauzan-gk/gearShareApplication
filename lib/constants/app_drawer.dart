import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.navy),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                SizedBox(width: 12),
                Text(
                  "GearShare",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── MAIN NAVIGATION ITEMS ────────────────────────
          // Only top-level destinations go here. Screens like Edit Profile,
          // Ratings, and Settings are reached FROM the Profile screen itself
          // (see the Account section in the ProfileScreen design) — not from
          // the drawer directly. This keeps the drawer from getting cluttered.
          _drawerTile(context, Icons.home_outlined, "Home", '/home'),
          _drawerTile(
            context,
            Icons.grid_view_outlined,
            "Browse & Search",
            '/browse-search',
          ),
          _drawerTile(
            context,
            Icons.category_outlined,
            "Categories",
            '/category',
          ),
          _drawerTile(
            context,
            Icons.list_alt_outlined,
            "My Listings",
            '/my-listings',
          ),
          _drawerTile(context, Icons.add_box_outlined, "Add Item", '/add-item'),
          _drawerTile(
            context,
            Icons.history,
            "Rental History",
            '/rental-history',
          ),
          _drawerTile(
            context,
            Icons.assignment_outlined,
            "Manage Requests",
            '/manage-requests',
          ),
          _drawerTile(context, Icons.person_outline, "Profile", '/profile'),

          const Spacer(), // pushes logout to the bottom

          const Divider(height: 1),
          _drawerTile(
            context,
            Icons.logout,
            "Logout",
            '/login',
            isLogout: true,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _drawerTile(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    bool isLogout = false,
  }) {
    final bool isActive = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? AppColors.error
            : (isActive ? AppColors.primary : AppColors.textSecondary),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isLogout
              ? AppColors.error
              : (isActive ? AppColors.primary : AppColors.textPrimary),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      tileColor: isActive ? AppColors.primary.withOpacity(0.08) : null,
      onTap: () {
        Navigator.pop(context);
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
