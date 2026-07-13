import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import '../constants/custom_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────
// USER PROFILE MODEL
// Plain data holder — Phase 3: this comes from the logged-in
// user's Firestore document instead of hardcoded values.
// ─────────────────────────────────────────────────────────────
class UserProfile {
  final String name;
  final String location;
  final int listings;
  final int rentals;
  final double rating;

  const UserProfile({
    required this.name,
    required this.location,
    required this.listings,
    required this.rentals,
    required this.rating,
  });

  UserProfile copyWith({String? name, String? location}) => UserProfile(
    name: name ?? this.name,
    location: location ?? this.location,
    listings: listings,
    rentals: rentals,
    rating: rating,
  );
}

// ─────────────────────────────────────────────────────────────
// PROFILE SCREEN
// StatefulWidget because the notification count and the profile
// data itself (name/location) can change while the screen is open.
// ─────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile _profile = const UserProfile(
    name: 'Urooj Fatima',
    location: 'Abbottabad, Pakistan',
    listings: 12,
    rentals: 18,
    rating: 4.8,
  );

  int _notifCount = 3;

  void _clearNotifications() {
    setState(() => _notifCount = 0);
    _showSnack('Notifications cleared');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── NAVIGATION HANDLERS ──────────────────────────────────
  void _openEditProfile() async {
    final updated = await Navigator.pushNamed(
      context,
      '/edit-profile',
      arguments: _profile,
    );
    if (updated != null && updated is UserProfile) {
      setState(() => _profile = updated);
      _showSnack('Profile updated');
    }
  }

  void _openRatings() => Navigator.pushNamed(context, '/ratings');

  void _openSettings() => Navigator.pushNamed(context, '/settings');

  void _shareProfile() => _showSnack('Share link copied: rentapp.co/@urooj');

  void _openPrivacy() => _showSnack('Privacy & Security — coming soon');

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log out?',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy),
        ),
        content: const Text(
          "You'll need to sign in again to access your account.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Profile',
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: _clearNotifications,
              ),
              if (_notifCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.navy, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$_notifCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/profile'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatCards(),
            ),
            const SizedBox(height: 24),
            _buildAccountSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────
  // Navy header with decorative circles (consistent with EditProfileScreen)
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      // Stack layers the decorative circles BEHIND the actual content
      child: Stack(
        children: [
          Positioned(top: -40, right: -30, child: _decorCircle(170)),
          Positioned(bottom: -30, left: -20, child: _decorCircle(120)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _openEditProfile,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.9),
                            width: 3,
                          ),
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primary,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _profile.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionBtn(
                      'Edit Profile',
                      filled: true,
                      onTap: _openEditProfile,
                    ),
                    const SizedBox(width: 10),
                    _actionBtn(
                      'Share Profile',
                      filled: false,
                      onTap: _shareProfile,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Small helper for decorative circles
  Widget _decorCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _actionBtn(
    String label, {
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: filled
              ? null
              : Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? AppColors.navy : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── STATS ──────────────────────────────────────────────────
  Widget _buildStatCards() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statCol(
              Icons.inventory_2_outlined,
              '${_profile.listings}',
              'Listings',
              AppColors.primary,
            ),
          ),
          Container(height: 50, width: 1, color: AppColors.border),
          Expanded(
            child: _statCol(
              Icons.calendar_today_outlined,
              '${_profile.rentals}',
              'Rentals',
              AppColors.navy,
            ),
          ),
          Container(height: 50, width: 1, color: AppColors.border),
          Expanded(
            child: _statCol(
              Icons.star_outline_rounded,
              _profile.rating.toString(),
              'Rating',
              AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCol(IconData icon, String val, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── ACCOUNT SECTION ────────────────────────────────────────
  Widget _buildAccountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          _tile(
            Icons.person_outline_rounded,
            'Edit Profile',
            'Update your info & photo',
            onTap: _openEditProfile,
          ),
          _tile(
            Icons.star_outline_rounded,
            'Ratings & Reviews',
            'See what renters say',
            onTap: _openRatings,
          ),
          _tile(
            Icons.settings_outlined,
            'Settings',
            'App preferences',
            onTap: _openSettings,
          ),
          _tile(
            Icons.shield_outlined,
            'Privacy & Security',
            'Manage your data',
            badge: 'NEW',
            onTap: _openPrivacy,
          ),
          _tile(
            Icons.logout_rounded,
            'Log Out',
            'Sign out of your account',
            isLogout: true,
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
    bool isLogout = false,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isLogout
                ? AppColors.error.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isLogout ? AppColors.error : AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isLogout ? AppColors.error : AppColors.navy,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            if (badge != null) const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isLogout ? AppColors.error : AppColors.textHint,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
