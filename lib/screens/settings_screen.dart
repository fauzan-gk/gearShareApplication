import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';

// ─────────────────────────────────────────────────────────────
// SETTINGS SCREEN
// StatefulWidget because switches (notifications, dark mode, etc.)
// need to remember their on/off state and rebuild when toggled.
// ─────────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle states — Phase 3: persist these to Shared Preferences
  // or the user's Firestore document instead of just in-memory.
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _locationServices = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Settings'),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── NOTIFICATIONS SECTION ─────────────────────────
            _SectionCard(
              title: 'Notifications',
              child: Column(
                children: [
                  _switchTile(
                    'Push Notifications',
                    Icons.notifications_active_outlined,
                    _pushNotifications,
                    (value) => setState(() => _pushNotifications = value),
                  ),
                  _switchTile(
                    'Email Notifications',
                    Icons.email_outlined,
                    _emailNotifications,
                    (value) => setState(() => _emailNotifications = value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── PRIVACY SECTION ────────────────────────────────
            _SectionCard(
              title: 'Privacy',
              child: _switchTile(
                'Location Services',
                Icons.location_on_outlined,
                _locationServices,
                (value) => setState(() => _locationServices = value),
              ),
            ),

            const SizedBox(height: 16),

            // ── APPEARANCE SECTION ─────────────────────────────
            _SectionCard(
              title: 'Appearance',
              child: _switchTile(
                'Dark Mode',
                Icons.dark_mode_outlined,
                _darkMode,
                (value) => setState(() => _darkMode = value),
              ),
            ),

            const SizedBox(height: 16),

            // ── ACCOUNT SECTION ─────────────────────────────────
            // Simple navigational tiles (no switches) — each one
            // would push to a dedicated screen or show a dialog.
            _SectionCard(
              title: 'Account',
              child: Column(
                children: [
                  _navTile(
                    context,
                    'Change Password',
                    Icons.lock_outline,
                    onTap: () {
                      // TODO Phase 3: navigate to a change-password flow
                      // backed by Firebase Authentication
                    },
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

            // ── LOGOUT BUTTON ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Clears the navigation stack and sends the user back
                  // to Login — pushReplacementNamed on its own would still
                  // leave Home/Profile etc. behind it in the stack, so we
                  // use pushNamedAndRemoveUntil to wipe everything.
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
                  side: BorderSide(color: AppColors.error.withOpacity(0.5)),
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

  // Reusable switch row — icon + label + Switch, no extra card needed
  // per row since _SectionCard already wraps the whole group.
  Widget _switchTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      secondary: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // Reusable navigational row — icon + label + chevron, tappable.
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
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.textHint,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION CARD WIDGET
// Same reusable pattern as AddItemScreen/EditItemScreen — groups
// related settings under one white card with a bold title.
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.06),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
