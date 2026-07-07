import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────
// EDIT PROFILE SCREEN
// StatefulWidget because text field values and switch toggles all
// change while the user interacts with the form.
//
// NOTE: This screen does NOT use the shared CustomAppBar / Drawer /
// BottomNav. It's a "drill-down" screen (only reachable by tapping
// "Edit Profile" from inside the Profile screen), so a custom header
// with just a back button is the correct pattern here — same as how
// your Add Item screen wouldn't want a Drawer buried three taps deep
// in a checkout-style flow. Global nav should only live on top-level
// destination screens.
// ─────────────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers pre-filled with the user's current info (dummy data for now).
  // Phase 3: these will be populated from the logged-in user's Firestore doc
  // instead of hardcoded strings.
  final TextEditingController nameController = TextEditingController(
    text: "Urooj Fatima",
  );
  final TextEditingController emailController = TextEditingController(
    text: "urooj@gmail.com",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "+92 300 1234567",
  );
  final TextEditingController locationController = TextEditingController(
    text: "Abbottabad, Pakistan",
  );
  final TextEditingController bioController = TextEditingController(
    text: "Photography lover • Adventure seeker • Renting quality gear.",
  );

  // Switch toggle states — the 'Switches' widget required in Phase 1.
  bool notifications = true;
  bool publicProfile = true;
  bool showPhone = false;

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
                        // TODO Phase 3: write updated fields to Firestore
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
  // Custom gradient-free navy header (kept as its own widget, same
  // pattern as your reference ProfileScreen's _buildHeader) with a
  // back button, avatar, and camera-edit icon overlay.
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
      // Stack layers the decorative circles BEHIND the actual content —
      // purely visual, doesn't affect layout of the real widgets.
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
                      // Empty SizedBox balances the back icon's width so the
                      // title stays visually centered instead of shifting right.
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Avatar with camera-icon overlay — Stack lets the small
                  // camera badge sit ON TOP of the circle avatar's corner.
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

  // Small helper so we don't repeat the same BoxDecoration twice for
  // the two decorative background circles.
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

  // ── TEXT FIELD ────────────────────────────────────────────
  // Reusable labeled input field. Extracted here because we need the
  // SAME style (rounded white container + shadow + icon) for 5 fields —
  // writing this once avoids repeating ~25 lines five times (DRY).
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

  // ── SWITCH TILE ───────────────────────────────────────────
  // Reusable row: icon + label + Switch, wrapped in a white card.
  // Function(bool) onChanged is a callback — the PARENT decides what
  // happens when toggled (here, it just calls setState with the new value).
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

  // dispose() cleans up all 5 controllers when this screen closes.
  // Only ONE @override is valid here — the original had it duplicated,
  // which is a compile error in Dart.
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
