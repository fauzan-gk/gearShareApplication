import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../services/image_service.dart';

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
  final String listingId;

  const EditItemScreen({super.key, required this.listingId});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  // ── FORM KEY ──────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── CONTROLLERS ──────────────────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  // ── STATE VARIABLES ──────────────────────────────────────
  String? _selectedCategory = 'Cameras';
  String? _availability = 'Available';
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _isFeatured = false;
  String _condition = 'Good';
  List<String> _existingImageUrls = [];
  final List<PickedImage> _newImages = [];
  final List<String> _imagesToDelete = [];

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

  final List<String> _conditions = [
    'New',
    'Excellent',
    'Good',
    'Fair',
    'Needs Repair',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Cameras': Icons.camera_alt_outlined,
    'Electronics': Icons.devices_outlined,
    'Tools': Icons.construction_outlined,
    'Fashion': Icons.checkroom_outlined,
    'Sports': Icons.sports_soccer_outlined,
    'Instruments': Icons.music_note_outlined,
    'Camping': Icons.cabin_outlined,
    'Other': Icons.category_outlined,
  };

  // ─── INIT STATE ──────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _loadListing();
  }

  Future<void> _loadListing() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId)
          .get();

      if (!doc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing not found')),
        );
        Navigator.pop(context);
        return;
      }

      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _priceController.text = (data['price'] ?? 0).toString();
      _descriptionController.text = data['description'] ?? '';
      _locationController.text = data['location'] ?? '';
      _selectedCategory = data['category'] ?? 'Cameras';
      _availability = data['isAvailable'] == true ? 'Available' : 'Rented';
      _condition = data['condition'] ?? 'Good';
      _isFeatured = data['isFeatured'] ?? false;
      _existingImageUrls = (data['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      if (mounted) setState(() => _isInitialLoading = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load listing: $e'), backgroundColor: AppColors.error),
      );
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  // ─── DISPOSE METHOD ──────────────────────────────────────
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickNewImages() async {
    final images = await ImageService.pickImages(
      maxCount: 5 - _existingImageUrls.length - _newImages.length,
    );
    if (images.isNotEmpty) {
      setState(() => _newImages.addAll(images));
    }
  }

  void _removeExistingImage(int index) {
    final url = _existingImageUrls[index];
    setState(() {
      _imagesToDelete.add(url);
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  // ─── SAVE CHANGES METHOD ────────────────────────────────
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Delete removed images from storage
      for (final url in _imagesToDelete) {
        await ImageService.deleteImage(url);
      }

      // Upload new images
      final uid = FirebaseAuth.instance.currentUser?.uid;
      List<String> newlyUploadedUrls = [];
      if (_newImages.isNotEmpty && uid != null) {
        newlyUploadedUrls = await ImageService.uploadImages(
          _newImages,
          uid,
          'listings',
        );
      }

      final allImageUrls = [..._existingImageUrls, ...newlyUploadedUrls];

      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId)
          .update({
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'isAvailable': _availability == 'Available',
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'condition': _condition,
        'isFeatured': _isFeatured,
        'imageUrls': allImageUrls,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Changes saved successfully!'),
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save changes: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // ─── DELETE CONFIRMATION ─────────────────────────────────
  void _confirmDelete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Delete this listing?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to remove "${_nameController.text}"?'),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryFor(dialogContext)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await FirebaseFirestore.instance
                    .collection('listings')
                    .doc(widget.listingId)
                    .delete();
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${_nameController.text}" deleted'),
                    backgroundColor: AppColors.error,
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
                    content: Text('Failed to delete: $e'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── BUILD METHOD ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Listing'),

      body: _isInitialLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── PROGRESS INDICATOR ─────────────────────────
                    _buildProgressIndicator(),

                    const SizedBox(height: 16),

                    // ── PHOTO CARD ─────────────────────────────────
                    _SectionCard(
                      title: '📸 Photos',
                      subtitle: 'Manage listing images',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_existingImageUrls.isNotEmpty || _newImages.isNotEmpty)
                            SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _existingImageUrls.length +
                                    _newImages.length +
                                    (_existingImageUrls.length + _newImages.length < 5
                                        ? 1
                                        : 0),
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final totalExisting = _existingImageUrls.length;
                                  if (index < totalExisting) {
                                    return _buildExistingImageThumb(index);
                                  }
                                  final newIndex = index - totalExisting;
                                  if (newIndex < _newImages.length) {
                                    return _buildNewImageThumb(newIndex);
                                  }
                                  return _buildAddImageButton();
                                },
                              ),
                            ),
                          if (_existingImageUrls.isEmpty && _newImages.isEmpty)
                            _buildEmptyImageArea(),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${_existingImageUrls.length + _newImages.length}/5 photos',
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
                      subtitle: 'Update your item information',
                      child: Column(
                        children: [
                          // Item Name
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 50,
                            decoration: _buildInputDecoration(
                              'Item Name',
                              Icons.badge_outlined,
                            ).copyWith(counterText: ''),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Please enter an item name'
                                : null,
                          ),
                          const SizedBox(height: 8),

                          // Category dropdown
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
                            onChanged: (value) =>
                                setState(() => _condition = value!),
                          ),
                          const SizedBox(height: 14),

                          // Description field
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            maxLength: 500,
                            decoration:
                                _buildInputDecoration(
                                  'Description',
                                  Icons.notes_outlined,
                                ).copyWith(
                                  counterStyle: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textHintFor(context),
                                  ),
                                ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Please enter a description'
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── PRICING & AVAILABILITY CARD ────────────────
                    _SectionCard(
                      title: '💰 Pricing & Availability',
                      subtitle: 'Update rental terms',
                      child: Column(
                        children: [
                          // Price field
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

                          // Availability dropdown
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _availability == 'Available'
                                  ? AppColors.success.withValues(alpha: 0.05)
                                  : AppColors.warning.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _availability == 'Available'
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : AppColors.warning.withValues(alpha: 0.2),
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              initialValue: _availability,
                              decoration:
                                  _buildInputDecoration(
                                    '',
                                    Icons.event_available_outlined,
                                  ).copyWith(
                                    prefixIcon: Icon(
                                      _availability == 'Available'
                                          ? Icons.check_circle_outline
                                          : Icons.access_time_rounded,
                                      color: _availability == 'Available'
                                          ? AppColors.success
                                          : AppColors.warning,
                                      size: 20,
                                    ),
                                  ),
                              items: _availabilityOptions.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Icon(
                                        status == 'Available'
                                            ? Icons.check_circle_outline
                                            : Icons.access_time_rounded,
                                        color: status == 'Available'
                                            ? AppColors.success
                                            : AppColors.warning,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(status),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _availability = value),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Featured item switch
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
                    _buildSummaryCard(),

                    const SizedBox(height: 28),

                    // ── ACTION BUTTONS ─────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Saving...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _confirmDelete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Delete Listing',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── BUILD PROGRESS INDICATOR ────────────────────────────
  Widget _buildProgressIndicator() {
    final steps = ['Details', 'Photo', 'Pricing', 'Review'];
    int currentStep = 1;

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
                        child: Icon(
                          isActive ? Icons.check_rounded : null,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondaryFor(context),
                          size: 16,
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
                _availability == 'Available'
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                _availability ?? 'Unknown',
                _availability == 'Available'
                    ? AppColors.success
                    : AppColors.warning,
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

  // ─── IMAGE HELPERS ─────────────────────────────────────
  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickNewImages,
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
      onTap: _pickNewImages,
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
              'PNG, JPG or WEBP',
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

  Widget _buildExistingImageThumb(int index) {
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
            child: Image.network(
              _existingImageUrls[index],
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColors.backgroundFor(context),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
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
            onTap: () => _removeExistingImage(index),
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

  Widget _buildNewImageThumb(int index) {
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
              _newImages[index].bytes,
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
            onTap: () => _removeNewImage(index),
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
}

// ─────────────────────────────────────────────────────────────
// SECTION CARD WIDGET
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
        boxShadow: [
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
