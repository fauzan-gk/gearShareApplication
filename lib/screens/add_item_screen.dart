import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import '../constants/custom_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────
// ADD ITEM SCREEN
// StatefulWidget because this screen has data that CHANGES while
// the user interacts with it: text typed into fields, the selected
// category, and the availability toggle. A StatelessWidget can't
// hold this kind of changing state.
// ─────────────────────────────────────────────────────────────
class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // GlobalKey<FormState> lets us reach INTO the Form widget from outside
  // (e.g. to call .validate() on button press) without manually tracking
  // every field's validity ourselves.
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers let us READ and CLEAR text field input.
  // Without a controller, we'd have no way to grab what the user typed.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Simple fields that don't need a controller — just a variable that
  // setState() updates whenever the user picks something.
  String? _selectedCategory;
  bool _isAvailable = true;

  final List<String> _categories = [
    'Electronics',
    'Tools',
    'Fashion',
    'Sports',
    'Instruments',
    'Camping',
    'Other',
  ];

  // dispose() runs when this screen is removed from the widget tree.
  // Controllers hold onto memory/resources, so we MUST clean them up here
  // or we get a memory leak — this is required for every controller we create.
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // .validate() runs every field's `validator` function at once.
    // Returns true ONLY if every single field passed its check.
    if (_formKey.currentState!.validate()) {
      // TODO Phase 3: push this data to Firestore instead of a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Listing published successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Shared components — same AppBar/Drawer/BottomNav used everywhere.
      appBar: const CustomAppBar(title: 'Add Listing'),
      drawer: const AppDrawer(currentRoute: '/add-item'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),

      // Form wraps everything so all TextFormFields inside it share ONE
      // validation state, reachable through _formKey.
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PHOTO UPLOAD CARD ─────────────────────────
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
                        // Dashed-looking border effect using a normal solid
                        // border is simplest here; a true dashed border needs
                        // a separate package, which we're avoiding to keep
                        // things within the allowed widget list.
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
                            Icons.add_a_photo_outlined,
                            size: 26,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap to add a photo',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'PNG or JPG, up to 5MB',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
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

                    // Dropdown lets user pick ONE category from a fixed list —
                    // this is the 'Dropdown Button' widget required in Phase 1.
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: const Text('Select Category'),
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
                      // Called every time the user picks a different option.
                      // setState() tells Flutter "rebuild this screen, something changed".
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 14),

                    // maxLines > 1 turns a normal TextFormField into a small
                    // multi-line text area — no separate widget needed.
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: _buildInputDecoration(
                        'Description (optional)',
                        Icons.notes_outlined,
                      ),
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
                      // Shows a numeric keyboard with a decimal point key —
                      // better UX than the default keyboard for price entry.
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
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // SwitchListTile combines a label + a Switch in one row —
                    // the 'Switches' widget required in Phase 1.
                    // Styled to sit flush inside the card (no extra border/bg)
                    // since the card itself already provides that container.
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Available for rent now',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Turn off if the item is temporarily unavailable',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _isAvailable,
                      activeColor: AppColors.primary,
                      onChanged: (bool value) =>
                          setState(() => _isAvailable = value),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── PUBLISH BUTTON ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Publish Listing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shared InputDecoration styling helper — keeps every field's border,
  // padding, and focus/error colors IDENTICAL without repeating this
  // block for every single TextFormField (DRY principle).
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors
          .background, // slightly off-white so fields stand out inside the white card
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
// A reusable white card with a small bold title above the content.
// Used to group related form fields together (Photo / Item Details /
// Pricing) instead of dumping every field into one long flat list —
// this is the main thing that makes a form look "professional" rather
// than just a stack of text boxes.
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
