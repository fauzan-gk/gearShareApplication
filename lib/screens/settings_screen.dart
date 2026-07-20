import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      appBar: CustomAppBar(title: 'Settings'),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              context: context,
              title: 'Notifications',
              child: Column(
                children: [
                  _switchTile(
                    context,
                    'Push Notifications',
                    Icons.notifications_active_outlined,
                    true,
                    (_) {},
                  ),
                  _switchTile(
                    context,
                    'Email Notifications',
                    Icons.email_outlined,
                    false,
                    (_) {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              context: context,
              title: 'Privacy',
              child: _switchTile(
                context,
                'Location Services',
                Icons.location_on_outlined,
                true,
                (_) {},
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              context: context,
              title: 'Appearance',
              child: _switchTile(
                context,
                'Dark Mode',
                Icons.dark_mode_outlined,
                isDark,
                (value) => themeProvider.setDarkMode(value),
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              context: context,
              title: 'Account',
              child: Column(
                children: [
                  _navTile(
                    context,
                    'Change Password',
                    Icons.lock_outline,
                    onTap: () {},
                  ),
                  _navTile(
                    context,
                    'Privacy Policy',
                    Icons.shield_outlined,
                    onTap: () {},
                  ),
                  _navTile(
                    context,
                    'Terms of Service',
                    Icons.description_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.primary,
      secondary: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textPrimaryFor(context),
        ),
      ),
    );
  }

  Widget _navTile(
    BuildContext context,
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textPrimaryFor(context),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.textHintFor(context),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final BuildContext context;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.context,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(ctx),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.navyFor(ctx).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryFor(ctx),
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
