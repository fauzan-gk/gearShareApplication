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
  final TextEditingController _locationController = TextEditingController();

  // Simple fields that don't need a controller — just a variable that
  // setState() updates whenever the user picks something.
  String? _selectedCategory;
  bool _isAvailable = true;
  bool _isFeatured = false;
  String _condition = 'Good'; // New: Item condition

  final List<String> _categories = [
    'Electronics',
    'Tools',
    'Fashion',
    'Sports',
    'Instruments',
    'Camping',
    'Other',
  ];

  final List<String> _conditions = [
    'New',
    'Excellent',
    'Good',
    'Fair',
    'Needs Repair',
  ];

  // Map icons to categories for visual feedback
  final Map<String, IconData> _categoryIcons = {
    'Electronics': Icons.devices_outlined,
    'Tools': Icons.construction_outlined,
    'Fashion': Icons.checkroom_outlined,
    'Sports': Icons.sports_soccer_outlined,
    'Instruments': Icons.music_note_outlined,
    'Camping': Icons.cabin_outlined,
    'Other': Icons.category_outlined,
  };

  // dispose() runs when this screen is removed from the widget tree.
  // Controllers hold onto memory/resources, so we MUST clean them up here
  // or we get a memory leak — this is required for every controller we create.
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // .validate() runs every field's `validator` function at once.
    // Returns true ONLY if every single field passed its check.
    if (_formKey.currentState!.validate()) {
      // TODO Phase 3: push this data to Firestore instead of a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Listing published successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Optionally clear the form after submission
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _locationController.clear();
      setState(() {
        _selectedCategory = null;
        _isAvailable = true;
        _condition = 'Good';
      });
    }
  }

  // ─── PREVIEW DIALOG ─────────────────────────────────────────
  // Shows a preview of how the listing will look to renters
  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.preview_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Listing Preview'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image placeholder
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Item Name'
                          : _nameController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _selectedCategory ?? 'Category',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _isAvailable
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isAvailable ? 'Available' : 'Rented',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _isAvailable
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _priceController.text.isEmpty
                          ? 'Rs. 0/day'
                          : 'Rs. ${_priceController.text}/day',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (_descriptionController.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _descriptionController.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This is how your listing will appear to renters',
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Shared components — same AppBar/Drawer/BottomNav used everywhere.
      appBar: CustomAppBar(
        title: 'Add Listing',
        actions: [
          // Preview button - shows how the listing would look
          IconButton(
            icon: const Icon(Icons.preview_rounded, color: Colors.white),
            onPressed: _showPreviewDialog,
            tooltip: 'Preview listing',
          ),
        ],
      ),
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
              // ── PROGRESS INDICATOR ─────────────────────────
              // Shows the user their progress through the form
              _buildProgressIndicator(),

              const SizedBox(height: 16),

              // ── PHOTO UPLOAD CARD ─────────────────────────
              _SectionCard(
                title: '📸 Photos',
                subtitle: 'Add up to 5 photos of your item',
                child: Column(
                  children: [
                    // Main photo upload area with improved design
                    InkWell(
                      onTap: () {
                        // TODO Phase 4: integrate image_picker / camera here
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.06),
                              AppColors.primary.withValues(alpha: 0.02),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.15),
                                    AppColors.primary.withValues(alpha: 0.05),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 32,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tap to add photos',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PNG, JPG or WEBP • Max 5MB each',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // ── FIXED: Photo thumbnails ────────
                            // Wrapped in a Row with MainAxisSize.min and fixed width
                            // to prevent overflow
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildPhotoThumbnail(0),
                                const SizedBox(width: 4),
                                _buildPhotoThumbnail(1),
                                const SizedBox(width: 4),
                                _buildPhotoThumbnail(2),
                                const SizedBox(width: 4),
                                _buildPhotoThumbnail(3),
                                const SizedBox(width: 4),
                                _buildPhotoThumbnail(4, isAddMore: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── ITEM DETAILS CARD ─────────────────────────
              _SectionCard(
                title: '📋 Item Details',
                subtitle: 'Tell renters what you\'re offering',
                child: Column(
                  children: [
                    // Item Name with character counter
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 50,
                      decoration:
                          _buildInputDecoration(
                            'Item Name',
                            Icons.badge_outlined,
                          ).copyWith(
                            counterText:
                                '', // Hide counter, we'll show it differently
                          ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter an item name'
                          : null,
                    ),
                    const SizedBox(height: 8),

                    // Category dropdown with icon preview
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      hint: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text('Select Category'),
                        ],
                      ),
                      decoration: _buildInputDecoration(
                        '',
                        Icons.category_outlined,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                _categoryIcons[category] ??
                                    Icons.category_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 14),

                    // Condition dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _condition,
                      decoration: _buildInputDecoration(
                        'Condition',
                        Icons.ad_units_outlined,
                      ),
                      items: _conditions.map((condition) {
                        return DropdownMenuItem(
                          value: condition,
                          child: Row(
                            children: [
                              Icon(
                                condition == 'New'
                                    ? Icons.new_releases_rounded
                                    : condition == 'Excellent'
                                    ? Icons.star_rounded
                                    : condition == 'Good'
                                    ? Icons.check_circle_rounded
                                    : condition == 'Fair'
                                    ? Icons.warning_amber_rounded
                                    : Icons.build_rounded,
                                color: condition == 'New'
                                    ? Colors.green
                                    : condition == 'Excellent'
                                    ? Colors.blue
                                    : condition == 'Good'
                                    ? AppColors.primary
                                    : condition == 'Fair'
                                    ? Colors.orange
                                    : Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(condition),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _condition = value!),
                    ),
                    const SizedBox(height: 14),

                    // Description with character counter
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration:
                          _buildInputDecoration(
                            'Description (optional)',
                            Icons.notes_outlined,
                          ).copyWith(
                            counterStyle: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── PRICING & AVAILABILITY CARD ────────────────
              _SectionCard(
                title: '💰 Pricing & Availability',
                subtitle: 'Set your rental terms',
                child: Column(
                  children: [
                    // Price field with currency prefix
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
                            prefixIcon: Container(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 4,
                              ),
                              child: const Icon(
                                Icons.currency_rupee_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            prefixText: 'Rs. ',
                            prefixStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Price must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Location field
                    TextFormField(
                      controller: _locationController,
                      decoration: _buildInputDecoration(
                        'Location',
                        Icons.location_on_outlined,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter a location'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Availability Switch
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isAvailable
                            ? AppColors.success.withValues(alpha: 0.05)
                            : AppColors.warning.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isAvailable
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.warning.withValues(alpha: 0.2),
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Available for rent now',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          _isAvailable
                              ? 'Your item will be visible to renters'
                              : 'Your item will be hidden from renters',
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: _isAvailable,
                        activeThumbColor: AppColors.success,
                        activeTrackColor: AppColors.success.withValues(
                          alpha: 0.3,
                        ),
                        inactiveThumbColor: AppColors.warning,
                        inactiveTrackColor: AppColors.warning.withValues(
                          alpha: 0.3,
                        ),
                        onChanged: (bool value) =>
                            setState(() => _isAvailable = value),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Featured item switch (premium feature)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.withValues(alpha: 0.08),
                            Colors.amber.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.2),
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '⭐ Feature this listing',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.amber,
                          ),
                        ),
                        subtitle: const Text(
                          'Get more visibility for a small fee',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _isFeatured,
                        activeThumbColor: Colors.amber,
                        activeTrackColor: Colors.amber.withValues(alpha: 0.3),
                        onChanged: (bool value) =>
                            setState(() => _isFeatured = value),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── SUMMARY CARD ─────────────────────────────────
              // Shows a quick summary of what will be published
              _buildSummaryCard(),

              const SizedBox(height: 28),

              // ── PUBLISH BUTTON ─────────────────────────────
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Publish Listing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By publishing, you agree to our Terms & Conditions',
                    style: TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── BUILD PROGRESS INDICATOR ────────────────────────────
  Widget _buildProgressIndicator() {
    final steps = ['Details', 'Photos', 'Pricing', 'Publish'];
    int currentStep = 0; // Could be calculated based on filled fields

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          int idx = entry.key;
          String label = entry.value;
          bool isActive = idx <= currentStep;
          bool isLast = idx == steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textHint,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── BUILD PHOTO THUMBNAIL ───────────────────────────────
  // FIXED: Added fixed width and height to prevent overflow
  Widget _buildPhotoThumbnail(int index, {bool isAddMore = false}) {
    return Container(
      width: 32, // Fixed width
      height: 32, // Fixed height
      decoration: BoxDecoration(
        color: isAddMore
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAddMore
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Icon(
        isAddMore ? Icons.add_rounded : Icons.image_outlined,
        size: isAddMore ? 16 : 14,
        color: isAddMore ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  // ─── BUILD SUMMARY CARD ──────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Listing Summary',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSummaryItem(
                Icons.check_circle_rounded,
                _selectedCategory ?? 'No category',
                AppColors.primary,
              ),
              const SizedBox(width: 16),
              _buildSummaryItem(
                Icons.attach_money_rounded,
                _priceController.text.isEmpty
                    ? 'No price'
                    : 'Rs. ${_priceController.text}/day',
                AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildSummaryItem(
                _isAvailable
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                _isAvailable ? 'Available' : 'Hidden',
                _isAvailable ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 16),
              _buildSummaryItem(
                Icons.location_on_rounded,
                _locationController.text.isEmpty
                    ? 'No location'
                    : _locationController.text,
                AppColors.navy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── INPUT DECORATION HELPER ─────────────────────────────
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label.isNotEmpty ? label : null,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: icon != Icons.attach_money_outlined
          ? Icon(icon, color: AppColors.textSecondary, size: 20)
          : null,
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
// A reusable white card with a small bold title above the content.
// Used to group related form fields together (Photo / Item Details /
// Pricing) instead of dumping every field into one long flat list —
// this is the main thing that makes a form look "professional" rather
// than just a stack of text boxes.
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, this.subtitle, required this.child});

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
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
            ],
          ),
          if (subtitle != null) const SizedBox(height: 4),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
