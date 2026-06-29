import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({super.key});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers initialized with existing listing data
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  // Form States
  String? _selectedCategory = 'Cameras';
  String? _availability = 'Available';

  final List<String> _categories = [
    'Cameras',
    'Electronics',
    'Tools',
    'Fashion',
    'Sports',
    'Other',
  ];
  final List<String> _availabilityOptions = ['Available', 'Rented'];

  @override
  void initState() {
    super.initState();
    // Pre-populating data for editing
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
      // TODO: Handle update submission logic here
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saving Changes...')));
    }
  }

  void _deleteListing() {
    // TODO: Add confirmation dialog before deleting
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Listing Deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Edit Listing',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE PLACEHOLDER (Interactive)
              InkWell(
                onTap: () {
                  // TODO: Integrate image_picker logic here
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 44,
                        color: AppColors.primary.withOpacity(0.8),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Replace Photo',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Update Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // ITEM NAME
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _buildInputDecoration(
                  'Item Name',
                  Icons.badge_outlined,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter an item name'
                    : null,
              ),
              const SizedBox(height: 16),

              // CATEGORY DROPDOWN
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
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // PRICE PER DAY
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
                      prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter a price';
                  if (double.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // AVAILABILITY DROPDOWN
              DropdownButtonFormField<String>(
                value: _availability,
                decoration: _buildInputDecoration(
                  'Availability',
                  Icons.event_available_outlined,
                ),
                items: _availabilityOptions.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) => setState(() => _availability = value),
              ),
              const SizedBox(height: 32),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

              // DELETE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _deleteListing,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  // Shared InputDecoration styling helper matching AddItemScreen
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
