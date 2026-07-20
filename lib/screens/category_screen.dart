//
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final Color color;

  const CategoryModel({
    required this.name,
    required this.icon,
    required this.itemCount,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────
// CATEGORY SCREEN
// ─────────────────────────────────────────────────────────────
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _searchQuery = '';
  String _selectedView = 'grid'; // 'grid' or 'list'
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('listings').get();
      final Map<String, int> categoryCounts = {};
      final Set<String> categoryNames = {};
      for (var doc in snapshot.docs) {
        final cat = doc['category'] as String?;
        if (cat != null) {
          categoryNames.add(cat);
          categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
        }
      }
      final Map<String, IconData> categoryIcons = {
        'Cameras': Icons.camera_alt_outlined,
        'Electronics': Icons.speaker_outlined,
        'Tools': Icons.construction_outlined,
        'Fashion': Icons.checkroom_outlined,
        'Sports': Icons.sports_soccer_outlined,
        'Instruments': Icons.music_note_outlined,
        'Camping': Icons.cabin_outlined,
        'Other': Icons.category_outlined,
      };
      final Map<String, Color> categoryColors = {
        'Cameras': const Color(0xFF4A90D9),
        'Electronics': const Color(0xFF9B59B6),
        'Tools': const Color(0xFFE67E22),
        'Fashion': const Color(0xFFE74C3C),
        'Sports': const Color(0xFF2ECC71),
        'Instruments': const Color(0xFFF39C12),
        'Camping': const Color(0xFF1ABC9C),
        'Other': const Color(0xFF95A5A6),
      };
      setState(() {
        _categories = categoryNames.map((name) => CategoryModel(
              name: name,
              icon: categoryIcons[name] ?? Icons.category_outlined,
              itemCount: categoryCounts[name] ?? 0,
              color: categoryColors[name] ?? const Color(0xFF95A5A6),
            )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<CategoryModel> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Categories',
        actions: [
          // View toggle button
          IconButton(
            icon: Icon(
              _selectedView == 'grid'
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _selectedView = _selectedView == 'grid' ? 'list' : 'grid';
              });
            },
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/category'),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── SEARCH CARD ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceFor(context),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.navyFor(context).withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Find a category...',
                        hintStyle:
                            TextStyle(color: AppColors.textHintFor(context)),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondaryFor(context),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: AppColors.textHintFor(context),
                                ),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surfaceFor(context),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
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
                      style:
                          TextStyle(color: AppColors.textPrimaryFor(context)),
                    ),
                  ),
                ),

                // ── QUICK STATS ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.category_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_filteredCategories.length} Categories',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (_searchQuery.isNotEmpty)
                        Text(
                          '${_filteredCategories.length} results',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryFor(context),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── GRID or LIST ──────────────────────────────────
                Expanded(
                  child: _filteredCategories.isEmpty
                      ? _buildEmptyState()
                      : _selectedView == 'grid'
                          ? _buildGridView()
                          : _buildListView(),
                ),
              ],
            ),
    );
  }

  // ─── GRID VIEW ────────────────────────────────────────────
  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _filteredCategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.95,
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
    );
  }

  // ─── LIST VIEW ────────────────────────────────────────────
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
        return _CategoryListItem(
          category: category,
          onTap: () => Navigator.pushNamed(
            context,
            '/browse-search',
            arguments: {'category': category.name},
          ),
        );
      },
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Categories Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryFor(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(
                  fontSize: 14, color: AppColors.textSecondaryFor(context)),
            ),
            const SizedBox(height: 20),
            if (_searchQuery.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.clear_rounded, size: 18),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CATEGORY CARD (Grid View)
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
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyFor(context).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container with category color
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    category.color.withValues(alpha: 0.2),
                    category.color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: category.color.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(category.icon, color: category.color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryFor(context),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${category.itemCount} items',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CATEGORY LIST ITEM (List View)
// ─────────────────────────────────────────────────────────────
class _CategoryListItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _CategoryListItem({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyFor(context).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    category.color.withValues(alpha: 0.2),
                    category.color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: category.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryFor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.itemCount} items available',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryFor(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
