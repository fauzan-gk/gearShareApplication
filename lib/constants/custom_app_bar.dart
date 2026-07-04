import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable AppBar used on every screen so the top bar always looks the same.
/// Implements PreferredSizeWidget because Scaffold's `appBar:` property
/// requires a widget that reports its own height (kToolbarHeight).
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 0.2,
        ),
      ),
      backgroundColor: AppColors.navy,
      elevation:
          0, // flat look is more "professional app" than a hard drop shadow
      centerTitle: true,
      // Scaffold auto-generates the hamburger icon on the left WHEN the
      // Scaffold has a `drawer:` set — we don't build that button manually.
      actions: actions,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
