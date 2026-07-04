import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import '../constants/custom_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────
class ListingItem {
  final String name;
  final String category;
  final double pricePerDay;
  final bool isAvailable;
  final IconData placeholderIcon;

  const ListingItem({
    required this.name,
    required this.category,
    required this.pricePerDay,
    required this.isAvailable,
    required this.placeholderIcon,
  });
}

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  static const List<ListingItem> _listings = [
    ListingItem(
      name: 'Sony A7III Camera',
      category: 'Cameras',
      pricePerDay: 500,
      isAvailable: true,
      placeholderIcon: Icons.camera_alt_outlined,
    ),
    ListingItem(
      name: 'JBL Speaker Set',
      category: 'Audio',
      pricePerDay: 200,
      isAvailable: false,
      placeholderIcon: Icons.speaker_outlined,
    ),
    ListingItem(
      name: 'Power Drill',
      category: 'Tools',
      pricePerDay: 150,
      isAvailable: true,
      placeholderIcon: Icons.construction_outlined,
    ),
    ListingItem(
      name: 'Acoustic Guitar',
      category: 'Instruments',
      pricePerDay: 300,
      isAvailable: true,
      placeholderIcon: Icons.music_note_outlined,
    ),
    ListingItem(
      name: '4P Camping Tent',
      category: 'Camping',
      pricePerDay: 350,
      isAvailable: false,
      placeholderIcon: Icons.cabin_outlined,
    ),
    ListingItem(
      name: 'Football Kit',
      category: 'Sports',
      pricePerDay: 100,
      isAvailable: true,
      placeholderIcon: Icons.sports_soccer_outlined,
    ),
  ];

  void _confirmDelete(BuildContext context, String itemName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete listing?'),
        content: Text('Are you sure you want to remove "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext), // Phase 3: Firestore delete
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = _listings.where((l) => l.isAvailable).length;
    final rentedCount = _listings.where((l) => !l.isAvailable).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'My Listings'),
      drawer: const AppDrawer(currentRoute: '/my-listings'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),

      // SingleChildScrollView lets the whole page scroll as ONE unit
      // (stat card + grid together), instead of the grid scrolling
      // independently inside a fixed-height Expanded. This is what lets
      // the stat card visually "sit on top of" the navy AppBar cleanly.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── STAT CARD ───────────────────────────────────
            // White, elevated, rounded — replaces the old solid color banner.
            // This single change is what makes the top of the screen feel
            // like a proper app instead of a colored strip.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.inventory_2_outlined,
                        value: '${_listings.length}',
                        label: 'Total',
                        color: AppColors.navy,
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.check_circle_outline,
                        value: '$availableCount',
                        label: 'Available',
                        color: AppColors.success,
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.access_time,
                        value: '$rentedCount',
                        label: 'Rented',
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── SECTION LABEL ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Your gear',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // ── LISTINGS GRID ──────────────────────────────────
            // shrinkWrap + NeverScrollableScrollPhysics because the OUTER
            // SingleChildScrollView already handles scrolling — without
            // these two properties, Flutter throws "unbounded height" errors
            // when a GridView is nested inside another scrollable.
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _listings.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final item = _listings[index];
                return _ListingCard(
                  item: item,
                  onEdit: () => Navigator.pushNamed(context, '/edit-item'),
                  onDelete: () => _confirmDelete(context, item.name),
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-item'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add listing',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _verticalDivider() =>
      Container(height: 44, width: 1, color: AppColors.border);
}

// ─────────────────────────────────────────────────────────────
// STAT ITEM WIDGET
// One column inside the stat card: icon + number + label.
// ─────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LISTING CARD WIDGET (unchanged structure, only color refs updated)
// ─────────────────────────────────────────────────────────────
class _ListingCard extends StatelessWidget {
  final ListingItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ListingCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    item.placeholderIcon,
                    size: 40,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.isAvailable
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.isAvailable ? 'Available' : 'Rented',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: item.isAvailable
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${item.pricePerDay.toInt()}/day',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Edit', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Delete', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
