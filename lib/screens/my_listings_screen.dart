import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import '../constants/custom_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────
// DATA MODEL — now built from Firestore documents
// ─────────────────────────────────────────────────────────────
class ListingItem {
  final String id;
  final String name;
  final String category;
  final double pricePerDay;
  final bool isAvailable;
  final DateTime dateAdded;

  ListingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerDay,
    required this.isAvailable,
    required this.dateAdded,
  });

  factory ListingItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingItem(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      category: data['category'] ?? 'Other',
      pricePerDay: (data['price'] ?? 0).toDouble(),
      isAvailable: data['isAvailable'] ?? true,
      dateAdded: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MY LISTINGS SCREEN
// ─────────────────────────────────────────────────────────────
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  String _filterStatus = 'all';
  String _sortBy = 'newest';
  String _viewMode = 'grid';

  List<ListingItem> _applyFiltersAndSort(List<ListingItem> items) {
    List<ListingItem> filtered = items.where((item) {
      if (_filterStatus == 'available') return item.isAvailable;
      if (_filterStatus == 'rented') return !item.isAvailable;
      return true;
    }).toList();

    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
    }

    return filtered;
  }

  void _confirmDelete(String itemId, String itemName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Delete listing?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to remove "$itemName"?'),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryFor(context),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await FirebaseFirestore.instance
                    .collection('listings')
                    .doc(itemId)
                    .delete();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"$itemName" deleted'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      appBar: CustomAppBar(
        title: 'My Listings',
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == 'grid'
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: Colors.white,
            ),
            onPressed: () => setState(() {
              _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
            }),
            tooltip: 'Toggle view',
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/my-listings'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('listings')
            .where('ownerId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(includeMetadataChanges: true), // ← add this
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('LISTINGS STREAM ERROR: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading listings: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasData) {
            debugPrint(
              'SNAPSHOT: ${snapshot.data!.docs.length} docs, '
              'fromCache=${snapshot.data!.metadata.isFromCache}, '
              'pendingWrites=${snapshot.data!.metadata.hasPendingWrites}',
            );
          }

          final allItems = snapshot.hasData
              ? snapshot.data!.docs
                    .map((doc) => ListingItem.fromFirestore(doc))
                    .toList()
              : <ListingItem>[];

          final filteredList = _applyFiltersAndSort(allItems);
          final availableCount = allItems.where((l) => l.isAvailable).length;
          final rentedCount = allItems.where((l) => !l.isAvailable).length;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── STAT CARD ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceFor(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navyFor(
                            context,
                          ).withValues(alpha: 0.08),
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
                            value: '${allItems.length}',
                            label: 'Total',
                            color: AppColors.textPrimaryFor(context),
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

                // ── SORT DROPDOWN ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        'Sort by:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryFor(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceFor(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderFor(context),
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: AppColors.textSecondaryFor(context),
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimaryFor(context),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'newest',
                                child: Text('Newest First'),
                              ),
                              DropdownMenuItem(
                                value: 'oldest',
                                child: Text('Oldest First'),
                              ),
                              DropdownMenuItem(
                                value: 'price_high',
                                child: Text('Price: High → Low'),
                              ),
                              DropdownMenuItem(
                                value: 'price_low',
                                child: Text('Price: Low → High'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _sortBy = value!),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filteredList.length} items',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── FILTER CHIPS ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Available', 'available'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Rented', 'rented'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── LISTINGS ─────────────────────────────
                filteredList.isEmpty
                    ? _buildEmptyState()
                    : _viewMode == 'grid'
                    ? _buildGridView(filteredList)
                    : _buildListView(filteredList),
              ],
            ),
          );
        },
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderFor(context),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondaryFor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<ListingItem> listings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: listings.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final item = listings[index];
          return _ListingCard(
            item: item,
            onEdit: () => Navigator.pushNamed(
              context,
              '/edit-item',
              arguments: {'itemId': item.id},
            ),
            onDelete: () => _confirmDelete(item.id, item.name),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<ListingItem> listings) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final item = listings[index];
        return _ListingListItem(
          item: item,
          onEdit: () => Navigator.pushNamed(
            context,
            '/edit-item',
            arguments: {'itemId': item.id},
          ),
          onDelete: () => _confirmDelete(item.id, item.name),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
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
              _filterStatus == 'all'
                  ? Icons.inbox_rounded
                  : Icons.search_off_rounded,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'all'
                ? 'No listings yet'
                : 'No $_filterStatus items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryFor(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _filterStatus == 'all'
                ? 'Start by adding your first gear listing'
                : 'Try changing the filter to see more items',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryFor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_filterStatus == 'all')
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/add-item'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Your First Listing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _verticalDivider() =>
      Container(height: 44, width: 1, color: AppColors.borderFor(context));
}

// ─────────────────────────────────────────────────────────────
// STAT ITEM WIDGET
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
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryFor(context),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LISTING CARD (Grid View)
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
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _iconForCategory(item.category),
                    size: 40,
                    color: AppColors.primary.withValues(alpha: 0.6),
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
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryFor(context),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimaryFor(context),
                      side: BorderSide(color: AppColors.borderFor(context)),
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
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
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

// ─────────────────────────────────────────────────────────────
// LISTING LIST ITEM (List View)
// ─────────────────────────────────────────────────────────────
class _ListingListItem extends StatelessWidget {
  final ListingItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ListingListItem({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
    return '${(difference.inDays / 30).floor()} months ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconForCategory(item.category),
              size: 28,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryFor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.isAvailable
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.isAvailable ? 'Available' : 'Rented',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: item.isAvailable
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${item.pricePerDay.toInt()}/day • ${item.category}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryFor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: AppColors.textSecondaryFor(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(item.dateAdded),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryFor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.textPrimaryFor(context),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 4),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
