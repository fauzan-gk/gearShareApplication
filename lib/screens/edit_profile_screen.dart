import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// Define a UserProfile model class (add this at the top level or in a separate file)
class UserProfile {
  final String name;
  final String location;
  // Add other fields as needed
  final String email;
  final String phone;
  final String bio;
  final bool notifications;
  final bool publicProfile;
  final bool showPhone;

  UserProfile({
    required this.name,
    required this.location,
    required this.email,
    required this.phone,
    required this.bio,
    required this.notifications,
    required this.publicProfile,
    required this.showPhone,
  });
}

class EditProfileScreen extends StatefulWidget {
  // Optional: accept an existing profile as argument
  final UserProfile? existingProfile;

  const EditProfileScreen({super.key, this.existingProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  bool notifications = true;
  bool publicProfile = true;
  bool showPhone = false;

  @override
  void initState() {
    super.initState();
    // If an existing profile was passed, populate the controllers with it
    if (widget.existingProfile != null) {
      nameController.text = widget.existingProfile!.name;
      emailController.text = widget.existingProfile!.email;
      phoneController.text = widget.existingProfile!.phone;
      locationController.text = widget.existingProfile!.location;
      bioController.text = widget.existingProfile!.bio;
      notifications = widget.existingProfile!.notifications;
      publicProfile = widget.existingProfile!.publicProfile;
      showPhone = widget.existingProfile!.showPhone;
    } else {
      // Default dummy data if no profile passed
      nameController.text = "Urooj Fatima";
      emailController.text = "urooj@gmail.com";
      phoneController.text = "+92 300 1234567";
      locationController.text = "Abbottabad, Pakistan";
      bioController.text =
          "Photography lover • Adventure seeker • Renting quality gear.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
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
                  _textField(
                    "Location",
                    Icons.location_on_outlined,
                    locationController,
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
                        color: AppColors.textPrimary,
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

                  // ── SAVE BUTTON ─────────────────────────
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
                      onPressed: () {
                        // Create updated profile object
                        final updatedProfile = UserProfile(
                          name: nameController.text,
                          location: locationController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          bio: bioController.text,
                          notifications: notifications,
                          publicProfile: publicProfile,
                          showPhone: showPhone,
                        );

                        // Pop the screen and return the updated profile
                        Navigator.pop(context, updatedProfile);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Profile updated successfully!',
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
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

  // ── HEADER ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
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
                        child: const CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.navyLight,
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.06),
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
              fillColor: AppColors.surface,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
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
    locationController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
