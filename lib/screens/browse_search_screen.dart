import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import '../constants/custom_bottom_nav.dart';

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
// StatefulWidget because:
// - the selected filter chip can change
// - the search text can change
// Both of these affect what's displayed → that's "state"
class BrowseSearchScreen extends StatefulWidget {
  const BrowseSearchScreen({super.key});

  @override
  State<BrowseSearchScreen> createState() => _BrowseSearchScreenState();
}

class _BrowseSearchScreenState extends State<BrowseSearchScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Guards against re-reading route arguments every rebuild —
  // didChangeDependencies() can run more than once, but we only
  // want to apply the incoming category ONE time.
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

  // didChangeDependencies() runs after initState(), once context/
  // inherited widgets (like ModalRoute) are actually available.
  // This is where we check if CategoryScreen sent us a category
  // to pre-filter by (Passing Data Between Screens — Phase 2 requirement).
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

  // ── Filtering logic ───────────────────────────────────────
  // Getter — recomputes filtered items fresh every time the UI
  // rebuilds. No need to store a separate filtered list.
  List<GearItem> get _filteredItems {
    return _allItems.where((item) {
      final matchesFilter =
          _selectedFilter == 'All' || item.category == _selectedFilter;
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

      // Same CustomAppBar used on every other screen now — no more
      // SliverAppBar. Consistency across screens matters more than
      // one screen having a "fancier" collapsing header.
      appBar: const CustomAppBar(title: 'Browse & Search'),
      drawer: const AppDrawer(currentRoute: '/browse-search'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),

      // SingleChildScrollView (not CustomScrollView/Slivers anymore) —
      // simpler scroll behavior, matching Category and My Listings screens.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SEARCH CARD ─────────────────────────────────
            // Identical position and style to CategoryScreen's search
            // card: a white, elevated, rounded container floating just
            // below the AppBar. This is the fix for the inconsistency —
            // both screens now place search in the exact same spot.
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
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search cameras, tools, tents...',
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

            const SizedBox(height: 20),

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

            // ── SECTION HEADER ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  const Text(
                    'Near Abbottabad',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── GEAR GRID ─────────────────────────────────────
            // shrinkWrap + NeverScrollableScrollPhysics since the OUTER
            // SingleChildScrollView already handles scrolling.
            _filteredItems.isEmpty
                ? _buildEmptyState()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return _GearCard(
                          item: item,
                          // Passing Data Between Screens: item name + price
                          // travel to ItemDetailScreen via onGenerateRoute,
                          // same pattern main.dart already sets up.
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/item-detail',
                            arguments: {
                              'itemName': item.name,
                              'itemPrice': item.pricePerDay.toInt().toString(),
                            },
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

  // ── Empty state when no results match ────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
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
  final VoidCallback onTap;

  const _GearCard({required this.item, required this.onTap});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  color: AppColors.primary.withOpacity(0.6),
                ),
              ),
            ),
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
      ),
    );
  }
}
