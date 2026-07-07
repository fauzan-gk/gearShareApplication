import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── ENTRY POINT ──────────────────────────────────────────────────────────────
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile',
      theme: ThemeData(fontFamily: 'SF Pro Display', useMaterial3: true),
      home: const MainShell(),
    );
  }
}

// ── MAIN SHELL (bottom nav state) ────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 4;

  final List<Widget> _pages = const [
    _PlaceholderPage(icon: Icons.home_outlined, label: "Home"),
    _PlaceholderPage(icon: Icons.grid_view_outlined, label: "Browse"),
    _PlaceholderPage(icon: Icons.add_circle_outline, label: "Add Item"),
    _PlaceholderPage(
      icon: Icons.chat_bubble_outline_rounded,
      label: "Messages",
    ),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F7),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderPage({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── PROFILE DATA MODEL ────────────────────────────────────────────────────────
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

  UserProfile copyWith({
    String? name,
    String? location,
    int? listings,
    int? rentals,
    double? rating,
  }) => UserProfile(
    name: name ?? this.name,
    location: location ?? this.location,
    listings: listings ?? this.listings,
    rentals: rentals ?? this.rentals,
    rating: rating ?? this.rating,
  );
}

// ── PROFILE SCREEN ────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile _profile = const UserProfile(
    name: "Urooj Fatima",
    location: "Abbottabad, Pakistan",
    listings: 12,
    rentals: 18,
    rating: 4.8,
  );

  int _notifCount = 3;

  void _clearNotifications() {
    setState(() => _notifCount = 0);
    _showSnack("Notifications cleared");
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xff1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openEditProfile() async {
    final updated = await showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(profile: _profile),
    );
    if (updated != null) {
      setState(() => _profile = updated);
      _showSnack("Profile updated");
    }
  }

  void _shareProfile() {
    _showSnack("Share link copied: rentapp.co/@urooj");
  }

  void _openRatings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _RatingsSheet(),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _SettingsSheet(),
    );
  }

  void _openPrivacy() {
    _showSnack("Privacy & Security — coming soon");
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Log out?",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "You'll need to sign in again to access your account.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack("Logged out");
            },
            child: const Text(
              "Log Out",
              style: TextStyle(
                color: Color(0xffFF3B30),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xffF2F2F7),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: _buildStatCards(),
              ),
              const SizedBox(height: 16),
              _buildAccountSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffFF9A2E), Color(0xffF4820A), Color(0xffE06A00)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          _orb(200, 0.10, top: -80, right: -60),
          _orb(120, 0.06, top: 10, right: 80),
          _orb(150, 0.07, bottom: -30, left: -50),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      _iconCircleBtn(
                        Icons.arrow_back_ios_new_rounded,
                        onTap: () {},
                      ),
                      const Spacer(),
                      const Text(
                        "My Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      _notifBtn(),
                    ],
                  ),
                ),
                _avatarBlock(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 32,
              child: CustomPaint(painter: _WavePainter()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(
    double size,
    double opacity, {
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }

  Widget _iconCircleBtn(IconData icon, {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );

  Widget _notifBtn() {
    return GestureDetector(
      onTap: _clearNotifications,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (_notifCount > 0)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xffF4820A),
                    width: 1.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    "$_notifCount",
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
    );
  }

  Widget _avatarBlock() {
    return Column(
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
                  color: Colors.white.withValues(alpha: 0.25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 3,
                  ),
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: Color(0xffF4820A),
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
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xffF4820A),
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
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xffF4820A),
                size: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                _profile.location,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _actionBtn("Edit Profile", filled: true, onTap: _openEditProfile),
            const SizedBox(width: 10),
            _actionBtn("Share Profile", filled: false, onTap: _shareProfile),
          ],
        ),
      ],
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
              : Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? const Color(0xffF4820A) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── STATS ──────────────────────────────────────────────────────────────────
  Widget _buildStatCards() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statCol(
              Icons.inventory_2_outlined,
              "${_profile.listings}",
              "LISTINGS",
              const Color(0xffFFF0E6),
              const Color(0xffF4820A),
            ),
          ),
          _vDiv(),
          Expanded(
            child: _statCol(
              Icons.calendar_today_outlined,
              "${_profile.rentals}",
              "RENTALS",
              const Color(0xffEEF2FF),
              const Color(0xff4C6EF5),
            ),
          ),
          _vDiv(),
          Expanded(
            child: _statCol(
              Icons.star_outline_rounded,
              _profile.rating.toString(),
              "RATING",
              const Color(0xffEDFAF0),
              const Color(0xff2DB55D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDiv() =>
      Container(height: 65, width: 0.5, color: const Color(0xffEEEEEE));

  Widget _statCol(
    IconData icon,
    String val,
    String label,
    Color bg,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 7),
          Text(
            val,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xffAAAAAA),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── ACCOUNT SECTION ────────────────────────────────────────────────────────
  Widget _buildAccountSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Account",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: _openSettings,
                child: const Text(
                  "See all",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xffF4820A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _tile(
            Icons.manage_accounts_outlined,
            "Edit Profile",
            "Update your info & photo",
            const Color(0xffFF6B35),
            const Color(0xffFFF0EB),
            onTap: _openEditProfile,
          ),
          _tile(
            Icons.star_outline_rounded,
            "Ratings & Reviews",
            "See what renters say",
            const Color(0xffFFAB00),
            const Color(0xffFFFAEB),
            onTap: _openRatings,
          ),
          _tile(
            Icons.settings_outlined,
            "Settings",
            "App preferences",
            const Color(0xff4C6EF5),
            const Color(0xffEEF2FF),
            onTap: _openSettings,
          ),
          _tile(
            Icons.shield_outlined,
            "Privacy & Security",
            "Manage your data",
            const Color(0xff7950F2),
            const Color(0xffF3EEFF),
            badge: "NEW",
            onTap: _openPrivacy,
          ),
          _tile(
            Icons.logout_rounded,
            "Log Out",
            "Sign out of your account",
            const Color(0xffFF3B30),
            const Color(0xffFFF0F0),
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
    String subtitle,
    Color iconColor,
    Color bgColor, {
    required VoidCallback onTap,
    bool isLogout = false,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isLogout
                              ? const Color(0xffFF3B30)
                              : const Color(0xff1A1A1A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xffB0B0B0),
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isLogout
                      ? const Color(0xffFF3B30)
                      : const Color(0xffD0D0D0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── EDIT PROFILE BOTTOM SHEET ─────────────────────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  final UserProfile profile;
  const _EditProfileSheet({required this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _locCtrl = TextEditingController(text: widget.profile.location);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Edit Profile",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),
          _field("Full Name", _nameCtrl, Icons.person_outline_rounded),
          const SizedBox(height: 14),
          _field("Location", _locCtrl, Icons.location_on_outlined),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffF4820A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  widget.profile.copyWith(
                    name: _nameCtrl.text.trim(),
                    location: _locCtrl.text.trim(),
                  ),
                );
              },
              child: const Text(
                "Save Changes",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff888888),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xffF4820A), size: 20),
            filled: true,
            fillColor: const Color(0xffF8F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ── RATINGS BOTTOM SHEET ──────────────────────────────────────────────────────
class _RatingsSheet extends StatelessWidget {
  const _RatingsSheet();

  static const _reviews = [
    ('Ayesha K.', 5, 'Super responsive, item was exactly as described!'),
    ('Bilal M.', 4, 'Great experience overall, would rent again.'),
    ('Sara N.', 5, 'Very trustworthy and friendly. Highly recommended.'),
    ('Hamza A.', 4, 'Good condition, prompt replies. Happy with rental.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                "Ratings & Reviews",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffEDFAF0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xff2DB55D),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "4.8",
                      style: TextStyle(
                        color: Color(0xff2DB55D),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._reviews.map((r) => _reviewTile(r.$1, r.$2, r.$3)),
        ],
      ),
    );
  }

  Widget _reviewTile(String name, int stars, String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xffFFF0E6),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Color(0xffF4820A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < stars
                        ? const Color(0xffFFAB00)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff666666),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SETTINGS BOTTOM SHEET ─────────────────────────────────────────────────────
class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet();

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  bool _notifications = true;
  bool _emailUpdates = false;
  bool _darkMode = false;
  bool _locationServices = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _toggle(
            "Push Notifications",
            "Alerts for new rentals",
            _notifications,
            (v) => setState(() => _notifications = v),
          ),
          _toggle(
            "Email Updates",
            "Weekly digest & promos",
            _emailUpdates,
            (v) => setState(() => _emailUpdates = v),
          ),
          _toggle(
            "Dark Mode",
            "Switch app appearance",
            _darkMode,
            (v) => setState(() => _darkMode = v),
          ),
          _toggle(
            "Location Services",
            "Improve listing discovery",
            _locationServices,
            (v) => setState(() => _locationServices = v),
          ),
        ],
      ),
    );
  }

  Widget _toggle(
    String title,
    String sub,
    bool val,
    ValueChanged<bool> onChange,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xffAAAAAA),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: val,
            onChanged: onChange,
            activeTrackColor: const Color(0xffF4820A),
          ),
        ],
      ),
    );
  }
}

// ── BOTTOM NAV ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffEEEEEE), width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _item(0, Icons.home_outlined, "Home"),
              _item(1, Icons.grid_view_outlined, "Browse"),
              _fab(),
              _item(3, Icons.chat_bubble_outline_rounded, "Messages"),
              _item(4, Icons.person_outline_rounded, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final active = currentIndex == index;
    final color = active ? const Color(0xffF4820A) : const Color(0xffC0C0C0);
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: active ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fab() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xffF4820A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x55F4820A),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 3),
          const Text(
            "Add Item",
            style: TextStyle(
              fontSize: 10,
              color: Color(0xffF4820A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── WAVE PAINTER ──────────────────────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xffF2F2F7);
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.44)
      ..quadraticBezierTo(
        size.width * 0.25,
        0,
        size.width * 0.5,
        size.height * 0.44,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.88,
        size.width,
        size.height * 0.44,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// import 'package:flutter/material.dart';

// const kOrange = Color(0xffF4820A);
// const kNavy = Color(0xff1B2A4A);
// const kNavyLight = Color(0xff2A3F6F);
// const kBg = Color(0xffF0F2F8);

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBg,
//       bottomNavigationBar: _buildBottomNav(),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(),
//             _buildStatCards(),
//             const SizedBox(height: 24),
//             _buildAccountSection(),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── HEADER ────────────────────────────────────────────────────────────
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [kNavy, kNavyLight],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(40),
//           bottomRight: Radius.circular(40),
//         ),
//       ),
//       child: Stack(
//         children: [
//           // Decorative circles
//           Positioned(
//             top: -30,
//             right: -30,
//             child: _decorCircle(170, kOrange, 0.12),
//           ),
//           Positioned(
//             top: 40,
//             right: 60,
//             child: _decorCircle(90, kOrange, 0.08),
//           ),
//           Positioned(
//             bottom: 20,
//             left: -20,
//             child: _decorCircle(130, kOrange, 0.1),
//           ),
//           Positioned(
//             bottom: -10,
//             right: 30,
//             child: _decorCircle(80, Colors.white, 0.05),
//           ),

//           // Dot grids
//           Positioned(top: 90, left: 12, child: _dotGrid()),
//           Positioned(top: 90, right: 12, child: _dotGrid()),

//           // Content
//           SafeArea(
//             bottom: false,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 30),
//               child: Column(
//                 children: [
//                   // Top bar
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 15,
//                     ),
//                     child: Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () {},
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.12),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Icon(
//                               Icons.arrow_back_ios_new,
//                               color: Colors.white,
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                         const Spacer(),
//                         const Text(
//                           "My Profile",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 0.3,
//                           ),
//                         ),
//                         const Spacer(),
//                         // Notification bell
//                         Stack(
//                           clipBehavior: Clip.none,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.12),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Icon(
//                                 Icons.notifications_none,
//                                 color: Colors.white,
//                                 size: 22,
//                               ),
//                             ),
//                             Positioned(
//                               top: 2,
//                               right: 2,
//                               child: Container(
//                                 height: 16,
//                                 width: 16,
//                                 decoration: const BoxDecoration(
//                                   color: kOrange,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Center(
//                                   child: Text(
//                                     "3",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Avatar
//                   Stack(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: kOrange, width: 3),
//                           boxShadow: [
//                             BoxShadow(
//                               color: kOrange.withOpacity(0.35),
//                               blurRadius: 20,
//                               offset: const Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         child: const CircleAvatar(
//                           radius: 58,
//                           backgroundColor: Color(0xff243558),
//                           child: Icon(Icons.person, size: 65, color: kOrange),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 2,
//                         right: 2,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: kOrange,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: kOrange.withOpacity(0.4),
//                                 blurRadius: 8,
//                               ),
//                             ],
//                           ),
//                           padding: const EdgeInsets.all(7),
//                           child: const Icon(
//                             Icons.camera_alt,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 14),

//                   // Name + verified badge
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         "Urooj Fatima",
//                         style: TextStyle(
//                           fontSize: 26,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 0.2,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: const BoxDecoration(
//                           color: kOrange,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.check,
//                           color: Colors.white,
//                           size: 12,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 10),

//                   // Location pill
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.2),
//                         width: 1,
//                       ),
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.location_on, color: kOrange, size: 16),
//                         SizedBox(width: 5),
//                         Text(
//                           "Abbottabad, Pakistan",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _decorCircle(double size, Color color, double opacity) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: color.withOpacity(opacity),
//       ),
//     );
//   }

//   Widget _dotGrid() {
//     return Column(
//       children: List.generate(
//         4,
//         (row) => Row(
//           children: List.generate(
//             4,
//             (col) => Container(
//               margin: const EdgeInsets.all(3),
//               width: 4,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── STAT CARDS ────────────────────────────────────────────────────────
//   Widget _buildStatCards() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: kNavy.withOpacity(0.08),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: _statItem(
//                 Icons.inventory_2_outlined,
//                 "12",
//                 "Listings",
//                 kOrange.withOpacity(0.1),
//                 kOrange,
//               ),
//             ),
//             _verticalDivider(),
//             Expanded(
//               child: _statItem(
//                 Icons.calendar_today_outlined,
//                 "18",
//                 "Rentals",
//                 kNavy.withOpacity(0.08),
//                 kNavy,
//               ),
//             ),
//             _verticalDivider(),
//             Expanded(
//               child: _statItem(
//                 Icons.star_outline,
//                 "4.8",
//                 "Rating",
//                 kOrange.withOpacity(0.1),
//                 kOrange,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _verticalDivider() {
//     return Container(height: 70, width: 1, color: kBg);
//   }

//   Widget _statItem(
//     IconData icon,
//     String value,
//     String label,
//     Color bgColor,
//     Color color,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
//             child: Icon(icon, color: color, size: 22),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 3),
//           Text(
//             label,
//             style: const TextStyle(fontSize: 13, color: Color(0xff8A96A8)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── ACCOUNT SECTION ───────────────────────────────────────────────────
//   Widget _buildAccountSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Account",
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: kNavy,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _menuTile(
//             Icons.person_outline,
//             "Edit Profile",
//             kOrange,
//             kOrange.withOpacity(0.1),
//           ),
//           _menuTile(
//             Icons.star_outline,
//             "Ratings & Reviews",
//             kNavy,
//             kNavy.withOpacity(0.08),
//           ),
//           _menuTile(
//             Icons.settings_outlined,
//             "Settings",
//             kOrange,
//             kOrange.withOpacity(0.1),
//           ),
//           _menuTile(
//             Icons.shield_outlined,
//             "Privacy & Security",
//             kNavy,
//             kNavy.withOpacity(0.08),
//           ),
//           _menuTile(
//             Icons.logout,
//             "Logout",
//             const Color(0xffE53935),
//             const Color(0xffFFEBEB),
//             isLogout: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _menuTile(
//     IconData icon,
//     String title,
//     Color iconColor,
//     Color bgColor, {
//     bool isLogout = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: kNavy.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         leading: Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Icon(icon, color: iconColor, size: 22),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 15,
//             color: isLogout ? const Color(0xffE53935) : kNavy,
//           ),
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios_rounded,
//           size: 15,
//           color: isLogout ? const Color(0xffE53935) : Colors.grey.shade400,
//         ),
//         onTap: () {},
//       ),
//     );
//   }

//   // ── BOTTOM NAV ────────────────────────────────────────────────────────
//   Widget _buildBottomNav() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: kNavy.withOpacity(0.08),
//             blurRadius: 16,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _navItem(Icons.home_outlined, "Home", false),
//               _navItem(Icons.grid_view_outlined, "Browse", false),

//               // Center FAB
//               GestureDetector(
//                 onTap: () {},
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 52,
//                       height: 52,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [kOrange, Color(0xffFF9A3C)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: kOrange.withOpacity(0.45),
//                             blurRadius: 14,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.add,
//                         color: Colors.white,
//                         size: 26,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     const Text(
//                       "Add Item",
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: kOrange,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               _navItem(Icons.chat_bubble_outline, "Messages", false),
//               _navItem(Icons.person_outline, "Profile", true),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _navItem(IconData icon, String label, bool isActive) {
//     return GestureDetector(
//       onTap: () {},
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 24,
//             color: isActive ? kOrange : Colors.grey.shade400,
//           ),
//           const SizedBox(height: 3),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               color: isActive ? kOrange : Colors.grey.shade400,
//               fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
