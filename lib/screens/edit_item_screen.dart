import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';

// ─────────────────────────────────────────────────────────────
// EDIT ITEM SCREEN
// StatefulWidget because form field values, the selected category,
// and the availability dropdown all change while the user edits.
//
// NOTE: No Drawer or Bottom Nav here on purpose. This screen is only
// ever reached by tapping "Edit" on a specific listing (a drill-down,
// not a top-level destination) — same reasoning as EditProfileScreen.
// Because we got here via Navigator.pushNamed (a normal push, not
// pushReplacementNamed), Flutter's AppBar automatically shows a back
// arrow for us — we don't need to build one manually.
// ─────────────────────────────────────────────────────────────
class EditItemScreen extends StatefulWidget {
  const EditItemScreen({super.key});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // 'late' means these are declared here but assigned later, in
  // initState() — needed because their starting text depends on the
  // existing listing's data (Phase 3: passed in via route arguments
  // or fetched from Firestore, instead of hardcoded like now).
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  String? _selectedCategory = 'Cameras';
  String? _availability = 'Available';

  final List<String> _categories = [
    'Cameras',
    'Electronics',
    'Tools',
    'Fashion',
    'Sports',
    'Instruments',
    'Camping',
    'Other',
  ];
  final List<String> _availabilityOptions = ['Available', 'Rented'];

  // initState() runs ONCE when this screen is first created — the right
  // place to pre-fill controllers with existing data (as opposed to the
  // build() method, which can run many times).
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Sony A7III Camera');
    _priceController = TextEditingController(text: '500');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // TODO Phase 3: push updated fields to the item's Firestore document
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Changes saved successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Shows a confirmation Dialog Box before deleting — same pattern as
  // My Listings, since delete is a destructive/irreversible action and
  // should never fire from a single accidental tap.
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete this listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close the dialog
              Navigator.pop(context); // go back to My Listings
              // TODO Phase 3: delete the document from Firestore here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Listing deleted'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Edit Listing'),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PHOTO CARD ─────────────────────────────────
              _SectionCard(
                title: 'Photo',
                child: InkWell(
                  onTap: () {
                    // TODO Phase 4: integrate image_picker / camera here
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 26,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap to replace photo',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── ITEM DETAILS CARD ─────────────────────────
              _SectionCard(
                title: 'Item Details',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _buildInputDecoration(
                        'Item Name',
                        Icons.badge_outlined,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter an item name'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: _buildInputDecoration(
                        'Category',
                        Icons.category_outlined,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── PRICING & AVAILABILITY CARD ────────────────
              _SectionCard(
                title: 'Pricing & Availability',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          _buildInputDecoration(
                            'Price Per Day',
                            Icons.attach_money_outlined,
                          ).copyWith(
                            prefixText: 'Rs. ',
                            prefixStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter a price';
                        if (double.tryParse(value) == null)
                          return 'Please enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Availability as a Dropdown (rather than the Switch used
                    // in Add Item) since an existing listing might already be
                    // "Rented" — a third meaningful state beyond a simple on/off.
                    DropdownButtonFormField<String>(
                      value: _availability,
                      decoration: _buildInputDecoration(
                        'Availability',
                        Icons.event_available_outlined,
                      ),
                      items: _availabilityOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _availability = value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── SAVE BUTTON ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── DELETE BUTTON ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _confirmDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Delete Listing',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shared InputDecoration helper — identical styling to AddItemScreen
  // so both forms feel like part of the same app (DRY principle).
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION CARD WIDGET
// Same reusable card pattern as AddItemScreen — a white rounded
// container with a bold title above its content. Redefined here
// (rather than imported) since each screen file keeps its private
// helper widgets local, matching the pattern already used across
// your other screens (e.g. _SummaryChip, _ListingCard in My Listings).
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
