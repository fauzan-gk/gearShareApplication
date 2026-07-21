import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/location_service.dart';

class UserProfile {
  final String name;
  final String country;
  final String city;
  final String email;
  final String phone;
  final String bio;
  final bool notifications;
  final bool publicProfile;
  final bool showPhone;

  UserProfile({
    required this.name,
    required this.country,
    required this.city,
    required this.email,
    required this.phone,
    required this.bio,
    required this.notifications,
    required this.publicProfile,
    required this.showPhone,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      name: data['name'] ?? '',
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      bio: data['bio'] ?? '',
      notifications: data['notifications'] ?? true,
      publicProfile: data['publicProfile'] ?? true,
      showPhone: data['showPhone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'country': country,
    'city': city,
    'email': email,
    'phone': phone,
    'bio': bio,
    'notifications': notifications,
    'publicProfile': publicProfile,
    'showPhone': showPhone,
  };
}

class EditProfileScreen extends StatefulWidget {
  final UserProfile? existingProfile;

  const EditProfileScreen({super.key, this.existingProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String _selectedCountry = '';
  List<String> _countries = [];
  bool _loadingCountries = true;

  bool notifications = true;
  bool publicProfile = true;
  bool showPhone = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _loadProfile();
  }

  Future<void> _loadCountries() async {
    final list = await LocationService.fetchCountries();
    if (!mounted) return;
    setState(() {
      _countries = list;
      _loadingCountries = false;
    });
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final profile = UserProfile.fromFirestore(doc);
        nameController.text = profile.name;
        emailController.text = profile.email;
        phoneController.text = profile.phone;
        _selectedCountry = profile.country;
        cityController.text = profile.city;
        bioController.text = profile.bio;
        notifications = profile.notifications;
        publicProfile = profile.publicProfile;
        showPhone = profile.showPhone;
      }
    } catch (_) {
      // Use defaults if document doesn't exist or error occurs
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        _textField("Full Name", Icons.person_outline, nameController),
                        const SizedBox(height: 18),
                        _textField("Email", Icons.email_outlined, emailController),
                        const SizedBox(height: 18),
                        _textField(
                          "Phone Number",
                          Icons.phone_outlined,
                          phoneController,
                        ),
                        const SizedBox(height: 18),
                        _countryDropdown(),
                        const SizedBox(height: 18),
                        _textField(
                          "City",
                          Icons.location_city_outlined,
                          cityController,
                        ),
                        const SizedBox(height: 18),
                        _textField(
                          "Bio",
                          Icons.edit_note,
                          bioController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 30),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Preferences",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryFor(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _switchTile(
                          "Public Profile",
                          Icons.public,
                          publicProfile,
                          (value) => setState(() => publicProfile = value),
                        ),
                        _switchTile(
                          "Receive Notifications",
                          Icons.notifications_active_outlined,
                          notifications,
                          (value) => setState(() => notifications = value),
                        ),
                        _switchTile(
                          "Show Phone Number",
                          Icons.phone_android,
                          showPhone,
                          (value) => setState(() => showPhone = value),
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _saveProfile,
                            child: const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _countryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimaryFor(context),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _loadingCountries ? null : () => _pickCountry(),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceFor(context),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyFor(context).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.public_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCountry.isNotEmpty
                        ? _selectedCountry
                        : _loadingCountries
                            ? 'Loading...'
                            : 'Select country',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedCountry.isNotEmpty
                          ? AppColors.textPrimaryFor(context)
                          : AppColors.textHintFor(context),
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.textHintFor(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickCountry() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Country'),
        content: SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView(
              shrinkWrap: true,
              children: _countries.map((c) => ListTile(
                dense: true,
                title: Text(c, style: const TextStyle(fontSize: 14)),
                onTap: () => Navigator.pop(ctx, c),
              )).toList(),
            ),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      ),
    );
    if (result != null && mounted) {
      setState(() => _selectedCountry = result);
    }
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final profile = UserProfile(
      name: nameController.text,
      country: _selectedCountry,
      city: cityController.text,
      email: emailController.text,
      phone: phoneController.text,
      bio: bioController.text,
      notifications: notifications,
      publicProfile: publicProfile,
      showPhone: showPhone,
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(profile.toMap(), SetOptions(merge: true));

      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(profile.name);

      if (!mounted) return;

      Navigator.pop(context, profile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navyFor(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -40, right: -30, child: _decorCircle(170)),
          Positioned(bottom: -30, left: -20, child: _decorCircle(120)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 30,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 22),

                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.navyLightFor(context),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    "Update your personal information",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _textField(
    String label,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimaryFor(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.navyFor(context).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.surfaceFor(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _switchTile(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyFor(context).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimaryFor(context),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
