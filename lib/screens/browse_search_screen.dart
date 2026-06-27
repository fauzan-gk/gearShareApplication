import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ── Dummy data model ──────────────────────────────────────────
// In Phase 3 this will be a Firestore document.
// For now it's just a plain Dart class with hardcoded values.
class GearItem {
  final String name;
  final String owner;
  final String category;
  final double pricePerDay;
  final double rating;
  final IconData placeholderIcon; // replaces image until Firebase Storage

  const GearItem({
    required this.name,
    required this.owner,
    required this.category,
    required this.pricePerDay,
    required this.rating,
    required this.placeholderIcon,
  });
}

// ── Browse Screen ─────────────────────────────────────────────
// This is a StatefulWidget because:
// - the selected filter chip can change
// - the search text can change
// Both of these affect what's displayed → that's "state"
class BrowseSearchScreen extends StatefulWidget {
  const BrowseSearchScreen({super.key});

  @override
  State<BrowseSearchScreen> createState() => _BrowseSearchScreenState();
}

class _BrowseSearchScreenState extends State<BrowseSearchScreen> {
  // Which filter chip is currently selected
  String _selectedFilter = 'All';

  // The current search query
  String _searchQuery = '';

  // Filter options shown as chips
  final List<String> _filters = [
    'All',
    'Cameras',
    'Tools',
    'Audio',
    'Sports',
    'Camping',
    'Instruments',
  ];

  // Dummy gear listings
  final List<GearItem> _allItems = const [
    GearItem(
      name: 'Sony A7III Camera',
      owner: 'Ahmed R.',
      category: 'Cameras',
      pricePerDay: 500,
      rating: 4.9,
      placeholderIcon: Icons.camera_alt_outlined,
    ),
    GearItem(
      name: 'Power Drill Set',
      owner: 'Sara K.',
      category: 'Tools',
      pricePerDay: 150,
      rating: 4.7,
      placeholderIcon: Icons.construction_outlined,
    ),
    GearItem(
      name: '4P Camping Tent',
      owner: 'Ali M.',
      category: 'Camping',
      pricePerDay: 350,
      rating: 4.8,
      placeholderIcon: Icons.cabin_outlined,
    ),
    GearItem(
      name: 'JBL Speaker Set',
      owner: 'Nadia F.',
      category: 'Audio',
      pricePerDay: 200,
      rating: 4.6,
      placeholderIcon: Icons.speaker_outlined,
    ),
    GearItem(
      name: 'Canon EOS 90D',
      owner: 'Bilal U.',
      category: 'Cameras',
      pricePerDay: 400,
      rating: 4.5,
      placeholderIcon: Icons.camera_alt_outlined,
    ),
    GearItem(
      name: 'Football Kit',
      owner: 'Usman T.',
      category: 'Sports',
      pricePerDay: 100,
      rating: 4.3,
      placeholderIcon: Icons.sports_soccer_outlined,
    ),
    GearItem(
      name: 'Acoustic Guitar',
      owner: 'Hira A.',
      category: 'Instruments',
      pricePerDay: 300,
      rating: 4.8,
      placeholderIcon: Icons.music_note_outlined,
    ),
    GearItem(
      name: 'DJI Mic Wireless',
      owner: 'Zara N.',
      category: 'Audio',
      pricePerDay: 250,
      rating: 4.9,
      placeholderIcon: Icons.mic_outlined,
    ),
  ];

  // ── Filtering logic ───────────────────────────────────────
  // This is a getter — it computes filtered items fresh every time
  // the UI rebuilds. No need to store filtered list separately.
  List<GearItem> get _filteredItems {
    return _allItems.where((item) {
      // Check if item matches selected category filter
      final matchesFilter =
          _selectedFilter == 'All' || item.category == _selectedFilter;

      // Check if item matches search query (case-insensitive)
      final matchesSearch =
          _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.owner.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: CustomScrollView(
        // CustomScrollView lets us have a collapsible header (SliverAppBar)
        // combined with a scrollable grid below it — very professional pattern
        slivers: [
          // ── Sliver AppBar — scrolls away as user scrolls down ──
          SliverAppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            floating: true, // reappears when user scrolls up
            snap: true, // snaps fully open, never half-visible
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 56, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find gear near you',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Search TextField
                    TextField(
                      onChanged: (value) {
                        // setState tells Flutter: "something changed, rebuild the UI"
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search cameras, tools, tents...',
                        hintStyle: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
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
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Filter Chips + Grid — stays below the AppBar ────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Horizontal scrollable filter chips
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
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
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

                const SizedBox(height: 20),

                // Section header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredItems.length} items available',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Near Abbottabad',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── Gear Grid ────────────────────────────────────────
          _filteredItems.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _GearCard(item: _filteredItems[index]),
                      childCount: _filteredItems.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                  ),
                ),
        ],
      ),
    );
  }

  // ── Empty state when no results match ────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text(
            'No gear found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search or category',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Gear Card Widget ──────────────────────────────────────────
class _GearCard extends StatelessWidget {
  final GearItem item;
  const _GearCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder area
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                item.placeholderIcon,
                size: 44,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),

          // Card body
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'by ${item.owner}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${item.pricePerDay.toInt()}/day',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          item.rating.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
