import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import '../constants/custom_bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/image_service.dart';

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
  String _condition = 'Good';
  final List<PickedImage> _pickedImages = [];
  bool _isUploading = false;

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

  Future<void> _pickImages() async {
    final images = await ImageService.pickImages(
      maxCount: 5 - _pickedImages.length,
    );
    if (images.isNotEmpty) {
      setState(() => _pickedImages.addAll(images));
    }
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => _isUploading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in')),
        );
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final ownerName = userDoc.data()?['name'] as String? ?? 'Unknown';

      List<String> imageUrls = [];
      if (_pickedImages.isNotEmpty) {
        final urls = await ImageService.uploadImages(
          _pickedImages,
          uid,
          'listings',
        );
        imageUrls = urls;
      }

      await FirebaseFirestore.instance.collection('listings').add({
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'condition': _condition,
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'location': _locationController.text.trim(),
        'isAvailable': _isAvailable,
        'isFeatured': _isFeatured,
        'ownerId': uid,
        'ownerName': ownerName,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _isUploading = false);
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

      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _locationController.clear();
      setState(() {
        _selectedCategory = null;
        _isAvailable = true;
        _condition = 'Good';
        _pickedImages.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to publish: ${e is TimeoutException ? "Upload timed out — check Firebase Storage is enabled" : e}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                  color: AppColors.surfaceFor(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navyFor(context).withValues(alpha: 0.06),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _selectedCategory ?? 'Category',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryFor(context),
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
                          color: AppColors.textSecondaryFor(context),
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
                style: TextStyle(fontSize: 11, color: AppColors.textHintFor(context)),
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
                    if (_pickedImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _pickedImages.length +
                              (_pickedImages.length < 5 ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == _pickedImages.length) {
                              return _buildAddImageButton();
                            }
                            return _buildImageThumb(index);
                          },
                        ),
                      ),
                    if (_pickedImages.isEmpty) _buildEmptyImageArea(),
                    if (_pickedImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${_pickedImages.length}/5 photos selected',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHintFor(context),
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
                            color: AppColors.textSecondaryFor(context),
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
                            counterStyle: TextStyle(
                              fontSize: 11,
                              color: AppColors.textHintFor(context),
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
                            prefixStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryFor(context),
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
                      child: Material(
                        color: Colors.transparent,
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
                      child: Material(
                        color: Colors.transparent,
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
                      onPressed: _isUploading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.6),
                      ),
                      child: _isUploading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Uploading...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
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
                style: TextStyle(fontSize: 11, color: AppColors.textHintFor(context)),
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
                        color: isActive ? AppColors.primary : AppColors.borderFor(context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondaryFor(context),
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
                            : AppColors.textHintFor(context),
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
                      color: isActive ? AppColors.primary : AppColors.borderFor(context),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── BUILD ADD IMAGE BUTTON ──────────────────────────────
  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color: AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyImageArea() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 140,
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
              padding: const EdgeInsets.all(14),
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
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to add photos',
              style: TextStyle(
                color: AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'PNG, JPG or WEBP • Max 5MB each',
              style: TextStyle(
                color: AppColors.textHintFor(context),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumb(int index) {
    final img = _pickedImages[index];
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              img.bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.backgroundFor(context),
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textHintFor(context),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
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
          Text(
            '📋 Listing Summary',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryFor(context),
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
                AppColors.navyFor(context),
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
                color: AppColors.textSecondaryFor(context),
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
      labelStyle: TextStyle(color: AppColors.textSecondaryFor(context), fontSize: 14),
      prefixIcon: icon != Icons.attach_money_outlined
          ? Icon(icon, color: AppColors.textSecondaryFor(context), size: 20)
          : null,
      filled: true,
      fillColor: AppColors.backgroundFor(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.borderFor(context)),
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
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: AppColors.navyFor(context).withValues(alpha: 0.06),
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 11, color: AppColors.textHintFor(context)),
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
