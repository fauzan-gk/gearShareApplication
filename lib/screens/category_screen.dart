import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';

// ─────────────────────────────────────────────────────────────
// DATA MODEL
// One CategoryModel = one tile in the grid (name, icon, item count).
// ─────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// CATEGORY SCREEN
// Changed from StatelessWidget to StatefulWidget — the search text
// now needs to be STORED somewhere and trigger a rebuild every time
// it changes, which only a State object (with setState) can do.
// A StatelessWidget literally cannot hold changing data like this.
// ─────────────────────────────────────────────────────────────
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Holds whatever the user has typed into the search box so far.
  String _searchQuery = '';

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

  // A getter — recomputes the filtered list fresh every time the
  // widget rebuilds (i.e. every time setState() runs after typing).
  // Same pattern as _filteredItems in BrowseSearchScreen.
  List<CategoryModel> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Browse Categories'),
      drawer: const AppDrawer(currentRoute: '/category'),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SEARCH CARD ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  // THIS is the fix — every keystroke now calls setState(),
                  // which updates _searchQuery and triggers a rebuild.
                  // Without onChanged, Flutter has no way to know you typed
                  // anything at all.
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Find a category...',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ),

            // ── SECTION LABEL ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                _searchQuery.isEmpty ? 'All Categories' : 'Search Results',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // ── GRID or EMPTY STATE ───────────────────────────
            _filteredCategories.isEmpty
                ? _buildEmptyState()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.15,
                          ),
                      itemBuilder: (context, index) {
                        final category = _filteredCategories[index];
                        return _CategoryCard(
                          category: category,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/browse-search',
                            arguments: {'category': category.name},
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Shown when the typed search text matches NO category at all.
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: AppColors.textHint),
          const SizedBox(height: 14),
          const Text(
            'No categories found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CATEGORY CARD WIDGET
// ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
