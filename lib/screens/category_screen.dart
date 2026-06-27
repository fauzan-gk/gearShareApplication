import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// Each category needs a name, icon, item count, and color accent.
// We define a simple model class right here for now.
// Later in Phase 3 this will come from Firebase.
class CategoryModel {
  final String name;
  final IconData icon;
  final int itemCount;
  final Color accentColor;

  const CategoryModel({
    required this.name,
    required this.icon,
    required this.itemCount,
    required this.accentColor,
  });
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  // Hardcoded dummy data for Phase 1 — UI only
  static const List<CategoryModel> _categories = [
    CategoryModel(
      name: 'Cameras',
      icon: Icons.camera_alt_outlined,
      itemCount: 24,
      accentColor: Color(0xFFF4820A),
    ),
    CategoryModel(
      name: 'Power Tools',
      icon: Icons.construction_outlined,
      itemCount: 18,
      accentColor: Color(0xFF1B2A4A),
    ),
    CategoryModel(
      name: 'Audio Gear',
      icon: Icons.speaker_outlined,
      itemCount: 12,
      accentColor: Color(0xFFF4820A),
    ),
    CategoryModel(
      name: 'Camping',
      icon: Icons.cabin_outlined,
      itemCount: 31,
      accentColor: Color(0xFF1B2A4A),
    ),
    CategoryModel(
      name: 'Sports',
      icon: Icons.sports_soccer_outlined,
      itemCount: 27,
      accentColor: Color(0xFFF4820A),
    ),
    CategoryModel(
      name: 'Instruments',
      icon: Icons.music_note_outlined,
      itemCount: 9,
      accentColor: Color(0xFF1B2A4A),
    ),
    CategoryModel(
      name: 'Video & AV',
      icon: Icons.videocam_outlined,
      itemCount: 15,
      accentColor: Color(0xFFF4820A),
    ),
    CategoryModel(
      name: 'Electronics',
      icon: Icons.devices_outlined,
      itemCount: 20,
      accentColor: Color(0xFF1B2A4A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Browse Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ──────────────────────────────────
            // TextField with a search icon inside it
            TextField(
              decoration: InputDecoration(
                hintText: 'Find a category...',
                hintStyle: const TextStyle(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'All Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // ── Category Grid ────────────────────────────────
            // GridView.builder is used when you have a list of items.
            // crossAxisCount: 2 means 2 columns.
            // We wrap it in Expanded so it takes the remaining screen height.
            Expanded(
              child: GridView.builder(
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: 12, // horizontal gap between cards
                  mainAxisSpacing: 12, // vertical gap between cards
                  childAspectRatio: 1.1, // width:height ratio of each card
                ),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _CategoryCard(category: category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Card Widget ─────────────────────────────────────
// We extract this into its own widget for two reasons:
// 1. Keeps the build() method above clean and readable
// 2. This card can be reused anywhere in the app
class _CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // InkWell gives us the tap ripple effect
      onTap: () {
        // Navigation to filtered browse screen will be added in Phase 2
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          // Subtle shadow to lift the card off the background
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
            // Icon container with orange background tint
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(category.icon, color: AppColors.primary, size: 28),
            ),

            const SizedBox(height: 10),

            Text(
              category.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            Text(
              '${category.itemCount} items',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
