// import 'package:flutter/material.dart';
// import '../constants/app_colors.dart';
// import '../constants/custom_app_bar.dart';

// // ─────────────────────────────────────────────────────────────
// // EDIT ITEM SCREEN
// // StatefulWidget because form field values, the selected category,
// // and the availability dropdown all change while the user edits.
// //
// // NOTE: No Drawer or Bottom Nav here on purpose. This screen is only
// // ever reached by tapping "Edit" on a specific listing (a drill-down,
// // not a top-level destination) — same reasoning as EditProfileScreen.
// // Because we got here via Navigator.pushNamed (a normal push, not
// // pushReplacementNamed), Flutter's AppBar automatically shows a back
// // arrow for us — we don't need to build one manually.
// // ─────────────────────────────────────────────────────────────
// class EditItemScreen extends StatefulWidget {
//   const EditItemScreen({super.key});

//   @override
//   State<EditItemScreen> createState() => _EditItemScreenState();
// }

// class _EditItemScreenState extends State<EditItemScreen> {
//   final _formKey = GlobalKey<FormState>();

//   // 'late' means these are declared here but assigned later, in
//   // initState() — needed because their starting text depends on the
//   // existing listing's data (Phase 3: passed in via route arguments
//   // or fetched from Firestore, instead of hardcoded like now).
//   late final TextEditingController _nameController;
//   late final TextEditingController _priceController;

//   String? _selectedCategory = 'Cameras';
//   String? _availability = 'Available';

//   final List<String> _categories = [
//     'Cameras',
//     'Electronics',
//     'Tools',
//     'Fashion',
//     'Sports',
//     'Instruments',
//     'Camping',
//     'Other',
//   ];
//   final List<String> _availabilityOptions = ['Available', 'Rented'];

//   // initState() runs ONCE when this screen is first created — the right
//   // place to pre-fill controllers with existing data (as opposed to the
//   // build() method, which can run many times).
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: 'Sony A7III Camera');
//     _priceController = TextEditingController(text: '500');
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   void _saveChanges() {
//     if (_formKey.currentState!.validate()) {
//       // TODO Phase 3: push updated fields to the item's Firestore document
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Changes saved successfully!'),
//           backgroundColor: AppColors.success,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     }
//   }

//   // Shows a confirmation Dialog Box before deleting — same pattern as
//   // My Listings, since delete is a destructive/irreversible action and
//   // should never fire from a single accidental tap.
//   void _confirmDelete() {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete this listing?'),
//         content: const Text('This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(dialogContext); // close the dialog
//               Navigator.pop(context); // go back to My Listings
//               // TODO Phase 3: delete the document from Firestore here
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: const Text('Listing deleted'),
//                   backgroundColor: AppColors.error,
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               );
//             },
//             style: TextButton.styleFrom(foregroundColor: AppColors.error),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: const CustomAppBar(title: 'Edit Listing'),

//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── PHOTO CARD ─────────────────────────────────
//               _SectionCard(
//                 title: 'Photo',
//                 child: InkWell(
//                   onTap: () {
//                     // TODO Phase 4: integrate image_picker / camera here
//                   },
//                   borderRadius: BorderRadius.circular(14),
//                   child: Container(
//                     height: 140,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: AppColors.primary.withOpacity(0.06),
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(
//                         color: AppColors.primary.withOpacity(0.3),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: AppColors.primary.withOpacity(0.12),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             Icons.camera_alt_outlined,
//                             size: 26,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           'Tap to replace photo',
//                           style: TextStyle(
//                             color: AppColors.textPrimary,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // ── ITEM DETAILS CARD ─────────────────────────
//               _SectionCard(
//                 title: 'Item Details',
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _nameController,
//                       textCapitalization: TextCapitalization.words,
//                       decoration: _buildInputDecoration(
//                         'Item Name',
//                         Icons.badge_outlined,
//                       ),
//                       validator: (value) =>
//                           value == null || value.trim().isEmpty
//                           ? 'Please enter an item name'
//                           : null,
//                     ),
//                     const SizedBox(height: 14),

//                     DropdownButtonFormField<String>(
//                       value: _selectedCategory,
//                       decoration: _buildInputDecoration(
//                         'Category',
//                         Icons.category_outlined,
//                       ),
//                       items: _categories.map((category) {
//                         return DropdownMenuItem(
//                           value: category,
//                           child: Text(category),
//                         );
//                       }).toList(),
//                       onChanged: (value) =>
//                           setState(() => _selectedCategory = value),
//                       validator: (value) =>
//                           value == null ? 'Please select a category' : null,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // ── PRICING & AVAILABILITY CARD ────────────────
//               _SectionCard(
//                 title: 'Pricing & Availability',
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _priceController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       decoration:
//                           _buildInputDecoration(
//                             'Price Per Day',
//                             Icons.attach_money_outlined,
//                           ).copyWith(
//                             prefixText: 'Rs. ',
//                             prefixStyle: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.textPrimary,
//                             ),
//                           ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty)
//                           return 'Please enter a price';
//                         if (double.tryParse(value) == null)
//                           return 'Please enter a valid number';
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 14),

//                     // Availability as a Dropdown (rather than the Switch used
//                     // in Add Item) since an existing listing might already be
//                     // "Rented" — a third meaningful state beyond a simple on/off.
//                     DropdownButtonFormField<String>(
//                       value: _availability,
//                       decoration: _buildInputDecoration(
//                         'Availability',
//                         Icons.event_available_outlined,
//                       ),
//                       items: _availabilityOptions.map((status) {
//                         return DropdownMenuItem(
//                           value: status,
//                           child: Text(status),
//                         );
//                       }).toList(),
//                       onChanged: (value) =>
//                           setState(() => _availability = value),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 28),

//               // ── SAVE BUTTON ─────────────────────────────────
//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton(
//                   onPressed: _saveChanges,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: const Text(
//                     'Save Changes',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // ── DELETE BUTTON ────────────────────────────────
//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: OutlinedButton(
//                   onPressed: _confirmDelete,
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: AppColors.error,
//                     side: BorderSide(color: AppColors.error.withOpacity(0.5)),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: const Text(
//                     'Delete Listing',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Shared InputDecoration helper — identical styling to AddItemScreen
//   // so both forms feel like part of the same app (DRY principle).
//   InputDecoration _buildInputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(color: AppColors.textSecondary),
//       prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
//       filled: true,
//       fillColor: AppColors.background,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       enabledBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: AppColors.border),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: AppColors.primary, width: 2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: AppColors.error),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderSide: const BorderSide(color: AppColors.error, width: 2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // SECTION CARD WIDGET
// // Same reusable card pattern as AddItemScreen — a white rounded
// // container with a bold title above its content. Redefined here
// // (rather than imported) since each screen file keeps its private
// // helper widgets local, matching the pattern already used across
// // your other screens (e.g. _SummaryChip, _ListingCard in My Listings).
// // ─────────────────────────────────────────────────────────────
// class _SectionCard extends StatelessWidget {
//   final String title;
//   final Widget child;

//   const _SectionCard({required this.title, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.navy.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }
// }
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
  // ── FORM KEY ──────────────────────────────────────────────
  // GlobalKey<FormState> lets us reach INTO the Form widget from outside
  // (e.g. to call .validate() on button press) without manually tracking
  // every field's validity ourselves.
  final _formKey = GlobalKey<FormState>();

  // ── CONTROLLERS ──────────────────────────────────────────
  // 'late' means these are declared here but assigned later, in
  // initState() — needed because their starting text depends on the
  // existing listing's data (Phase 3: passed in via route arguments
  // or fetched from Firestore, instead of hardcoded like now).
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  // ── STATE VARIABLES ──────────────────────────────────────
  String? _selectedCategory = 'Cameras';
  String? _availability = 'Available';
  bool _isLoading = false;
  bool _isFeatured = false;

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

  String _condition = 'Good';

  // Map icons to categories for visual feedback
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
  // initState() runs ONCE when this screen is first created — the right
  // place to pre-fill controllers with existing data (as opposed to the
  // build() method, which can run many times).
  // Phase 3: This data will come from route arguments or Firestore.
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Sony A7III Camera');
    _priceController = TextEditingController(text: '500');
    _descriptionController = TextEditingController(
      text:
          'Professional grade camera with 24.2MP sensor, 4K video, and weather sealing.',
    );
    _locationController = TextEditingController(text: 'Abbottabad, Pakistan');
  }

  // ─── DISPOSE METHOD ──────────────────────────────────────
  // dispose() cleans up all controllers when this screen closes.
  // Controllers hold onto resources, so we MUST dispose them to prevent
  // memory leaks. This is required for EVERY TextEditingController.
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ─── SAVE CHANGES METHOD ────────────────────────────────
  // Validates and saves item changes.
  // Phase 3: This will write to Firestore instead of just showing a SnackBar.
  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Show loading state
      setState(() => _isLoading = true);

      // Simulate network delay (remove in Phase 3)
      await Future.delayed(const Duration(seconds: 1));

      // TODO Phase 3: push updated fields to the item's Firestore document
      // await FirebaseFirestore.instance
      //     .collection('listings')
      //     .doc(itemId)
      //     .update({
      //   'name': _nameController.text,
      //   'price': double.parse(_priceController.text),
      //   'category': _selectedCategory,
      //   'availability': _availability,
      //   'description': _descriptionController.text,
      //   'location': _locationController.text,
      //   'condition': _condition,
      //   'isFeatured': _isFeatured,
      // });

      // Hide loading state
      setState(() => _isLoading = false);

      // Show success message
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
    }
  }

  // ─── DELETE CONFIRMATION ─────────────────────────────────
  // Shows a confirmation Dialog Box before deleting — same pattern as
  // My Listings, since delete is a destructive/irreversible action and
  // should never fire from a single accidental tap.
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
            const Text('This action cannot be undone.'),
            const SizedBox(height: 8),
            Text(
              'All associated data will be permanently removed.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close the dialog
              // TODO Phase 3: delete the document from Firestore here
              // await FirebaseFirestore.instance
              //     .collection('listings')
              //     .doc(itemId)
              //     .delete();

              Navigator.pop(context); // go back to My Listings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Listing deleted successfully'),
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

  // ─── BUILD METHOD ──────────────────────────────────────────
  // The build method is called whenever:
  // 1. Widget is first created
  // 2. setState() is called (loading state changes)
  // 3. Parent widget rebuilds
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
              // ── PROGRESS INDICATOR ─────────────────────────
              // Shows edit progress steps
              _buildProgressIndicator(),

              const SizedBox(height: 16),

              // ── PHOTO CARD ─────────────────────────────────
              _SectionCard(
                title: '📸 Photo',
                subtitle: 'Replace the current photo',
                child: InkWell(
                  onTap: () {
                    // TODO Phase 4: integrate image_picker / camera here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo picker coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.06),
                          AppColors.primary.withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
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
                                AppColors.primary.withOpacity(0.15),
                                AppColors.primary.withOpacity(0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap to replace photo',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PNG, JPG or WEBP • Max 5MB',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12,
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
                title: '📋 Item Details',
                subtitle: 'Update your item information',
                child: Column(
                  children: [
                    // Item Name with character counter
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

                    // Category dropdown with icon preview
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
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
                      value: _condition,
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
                            counterStyle: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
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

                    // Availability dropdown with visual indicator
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _availability == 'Available'
                            ? AppColors.success.withOpacity(0.05)
                            : AppColors.warning.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _availability == 'Available'
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.warning.withOpacity(0.2),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _availability,
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

                    // Featured item switch (premium feature)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.withOpacity(0.08),
                            Colors.amber.withOpacity(0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.2),
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
                        activeColor: Colors.amber,
                        activeTrackColor: Colors.amber.withOpacity(0.3),
                        onChanged: (bool value) =>
                            setState(() => _isFeatured = value),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── SUMMARY CARD ─────────────────────────────────
              // Shows a quick summary of the listing
              _buildSummaryCard(),

              const SizedBox(height: 28),

              // ── ACTION BUTTONS ─────────────────────────────
              // Save button with loading state
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
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
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

              // Delete button (destructive action)
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
    int currentStep = 1; // Edit is step 2

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
                        child: Icon(
                          isActive ? Icons.check_rounded : null,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
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

  // ─── BUILD SUMMARY CARD ──────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
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
  // Shared InputDecoration helper — identical styling to AddItemScreen
  // so both forms feel like part of the same app (DRY principle).
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
// Same reusable card pattern as AddItemScreen — a white rounded
// container with a bold title above its content. Redefined here
// (rather than imported) since each screen file keeps its private
// helper widgets local, matching the pattern already used across
// your other screens (e.g. _SummaryChip, _ListingCard in My Listings).
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
            color: AppColors.navy.withOpacity(0.06),
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
