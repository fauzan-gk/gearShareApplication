import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import '../constants/custom_bottom_nav.dart';

// ── Firestore data model ──────────────────────────────────────
class GearItem {
  final String id;
  final String name;
  final String owner;
  final String category;
  final double pricePerDay;
  final double rating;
  final bool isAvailable;
  final String location;

  const GearItem({
    required this.id,
    required this.name,
    required this.owner,
    required this.category,
    required this.pricePerDay,
    required this.rating,
    required this.isAvailable,
    required this.location,
  });

  // Convert Firestore document to GearItem
  factory GearItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GearItem(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      owner: data['ownerName'] ?? 'Unknown',
      category: data['category'] ?? 'Other',
      pricePerDay: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      isAvailable: data['isAvailable'] ?? true,
      location: data['location'] ?? 'Unknown',
    );
  }
}

// ── Browse Screen ─────────────────────────────────────────────
class BrowseSearchScreen extends StatefulWidget {
  const BrowseSearchScreen({super.key});

  @override
  State<BrowseSearchScreen> createState() => _BrowseSearchScreenState();
}

class _BrowseSearchScreenState extends State<BrowseSearchScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  String _sortBy = 'relevance';
  bool _showFilters = false;
  bool _argumentsApplied = false;

  final List<String> _filters = [
    'All',
    'Cameras',
    'Tools',
    'Audio',
    'Sports',
    'Camping',
    'Instruments',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argumentsApplied) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['category'] != null) {
        final incomingCategory = args['category'] as String;
        if (_filters.contains(incomingCategory)) {
          _selectedFilter = incomingCategory;
        }
      }
      _argumentsApplied = true;
    }
  }

  // Filter and sort items client-side after fetching from Firestore
  List<GearItem> _applyFilters(List<GearItem> items) {
    var filtered = items.where((item) {
      final matchesFilter =
          _selectedFilter == 'All' || item.category == _selectedFilter;
      final matchesSearch =
          _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.owner.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Browse Gear',
        actions: [
          IconButton(
            icon: Icon(
              _showFilters
                  ? Icons.filter_list_rounded
                  : Icons.filter_list_outlined,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/browse-search'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),

      body: Column(
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
                    color: AppColors.navy.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search cameras, tools, tents...',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: AppColors.textHint,
                          ),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
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

          if (_showFilters) _buildExpandedFilters(),

          const SizedBox(height: 12),

          // ── FILTER CHIPS ──────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ── GEAR LIST WITH STREAMBUILDER ──────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Convert docs to GearItem list
                final allItems = snapshot.data!.docs
                    .map((doc) => GearItem.fromFirestore(doc))
                    .toList();

                // Apply filters and sort client-side
                final filteredItems = _applyFilters(allItems);

                return Column(
                  children: [
                    // Section header with count and sort
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${filteredItems.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'items found',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                icon: const Icon(
                                  Icons.sort_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'relevance',
                                    child: Text(
                                      'Relevance',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'price_low',
                                    child: Text(
                                      'Price: Low → High',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'price_high',
                                    child: Text(
                                      'Price: High → Low',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'rating',
                                    child: Text(
                                      'Top Rated',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _sortBy = value!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // List
                    Expanded(
                      child: filteredItems.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return _GearListItem(
                                  item: item,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/item-detail',
                                    arguments: {
                                      'itemName': item.name,
                                      'itemPrice':
                                          'Rs. ${item.pricePerDay.toInt()}/day',
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedFilters() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Filters',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildQuickFilterChip(
                'Available Now',
                Icons.check_circle_outline,
              ),
              _buildQuickFilterChip('Under Rs.300', Icons.attach_money),
              _buildQuickFilterChip('Near Me', Icons.location_on_outlined),
              _buildQuickFilterChip('Top Rated', Icons.star_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
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
            const Text(
              'No Gear Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isEmpty
                  ? 'No items in this category'
                  : 'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            if (_searchQuery.isNotEmpty || _selectedFilter != 'All')
              ElevatedButton.icon(
                onPressed: () => setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                }),
                icon: const Icon(Icons.clear_rounded, size: 18),
                label: const Text('Clear Filters'),
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

// ── Gear List Item ────────────────────────────────────────────
class _GearListItem extends StatelessWidget {
  final GearItem item;
  final VoidCallback onTap;

  const _GearListItem({required this.item, required this.onTap});

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Cameras':
        return Icons.camera_alt_outlined;
      case 'Tools':
        return Icons.construction_outlined;
      case 'Camping':
        return Icons.cabin_outlined;
      case 'Audio':
        return Icons.speaker_outlined;
      case 'Sports':
        return Icons.sports_soccer_outlined;
      case 'Instruments':
        return Icons.music_note_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _iconForCategory(item.category),
                      size: 32,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  if (!item.isAvailable)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Rented',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item.owner,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item.location,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            item.rating.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${item.pricePerDay.toInt()}/day',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (item.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
