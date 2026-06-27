import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final int itemCount;

  const CategoryModel({
    required this.name,
    required this.icon,
    required this.itemCount,
  });
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  static const List<CategoryModel> _categories = [
    CategoryModel(
      name: 'Cameras',
      icon: Icons.camera_alt_outlined,
      itemCount: 24,
    ),
    CategoryModel(
      name: 'Power Tools',
      icon: Icons.construction_outlined,
      itemCount: 18,
    ),
    CategoryModel(
      name: 'Audio Gear',
      icon: Icons.speaker_outlined,
      itemCount: 12,
    ),
    CategoryModel(name: 'Camping', icon: Icons.cabin_outlined, itemCount: 31),
    CategoryModel(
      name: 'Sports',
      icon: Icons.sports_soccer_outlined,
      itemCount: 27,
    ),
    CategoryModel(
      name: 'Instruments',
      icon: Icons.music_note_outlined,
      itemCount: 9,
    ),
    CategoryModel(
      name: 'Video & AV',
      icon: Icons.videocam_outlined,
      itemCount: 15,
    ),
    CategoryModel(
      name: 'Electronics',
      icon: Icons.devices_outlined,
      itemCount: 20,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── AppBar ──────────────────────────────────────────────
      // Orange AppBar — makes orange the dominant first impression
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Browse Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Orange-to-white gradient header section ──────────
          // This connects the AppBar to the body visually
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Find a category...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 1.5),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),

          // ── Section Label ────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'All Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // ── Grid ─────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  return _CategoryCard(category: _categories[index]);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Category Card ─────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Orange icon box
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(category.icon, color: AppColors.primary, size: 26),
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

            const SizedBox(height: 3),

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
