// import 'package:flutter/material.dart';
// import '../constants/app_colors.dart';
// import '../constants/custom_app_bar.dart';
// import '../constants/app_drawer.dart';
// import '../constants/custom_bottom_nav.dart';

// // ─────────────────────────────────────────────────────────────
// // DATA MODEL
// // ─────────────────────────────────────────────────────────────
// class ListingItem {
//   final String name;
//   final String category;
//   final double pricePerDay;
//   final bool isAvailable;
//   final IconData placeholderIcon;

//   const ListingItem({
//     required this.name,
//     required this.category,
//     required this.pricePerDay,
//     required this.isAvailable,
//     required this.placeholderIcon,
//   });
// }

// class MyListingsScreen extends StatelessWidget {
//   const MyListingsScreen({super.key});

//   static const List<ListingItem> _listings = [
//     ListingItem(
//       name: 'Sony A7III Camera',
//       category: 'Cameras',
//       pricePerDay: 500,
//       isAvailable: true,
//       placeholderIcon: Icons.camera_alt_outlined,
//     ),
//     ListingItem(
//       name: 'JBL Speaker Set',
//       category: 'Audio',
//       pricePerDay: 200,
//       isAvailable: false,
//       placeholderIcon: Icons.speaker_outlined,
//     ),
//     ListingItem(
//       name: 'Power Drill',
//       category: 'Tools',
//       pricePerDay: 150,
//       isAvailable: true,
//       placeholderIcon: Icons.construction_outlined,
//     ),
//     ListingItem(
//       name: 'Acoustic Guitar',
//       category: 'Instruments',
//       pricePerDay: 300,
//       isAvailable: true,
//       placeholderIcon: Icons.music_note_outlined,
//     ),
//     ListingItem(
//       name: '4P Camping Tent',
//       category: 'Camping',
//       pricePerDay: 350,
//       isAvailable: false,
//       placeholderIcon: Icons.cabin_outlined,
//     ),
//     ListingItem(
//       name: 'Football Kit',
//       category: 'Sports',
//       pricePerDay: 100,
//       isAvailable: true,
//       placeholderIcon: Icons.sports_soccer_outlined,
//     ),
//   ];

//   void _confirmDelete(BuildContext context, String itemName) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete listing?'),
//         content: Text('Are you sure you want to remove "$itemName"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () =>
//                 Navigator.pop(dialogContext), // Phase 3: Firestore delete
//             style: TextButton.styleFrom(foregroundColor: AppColors.error),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final availableCount = _listings.where((l) => l.isAvailable).length;
//     final rentedCount = _listings.where((l) => !l.isAvailable).length;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: const CustomAppBar(title: 'My Listings'),
//       drawer: const AppDrawer(currentRoute: '/my-listings'),
//       bottomNavigationBar: const CustomBottomNav(currentIndex: 3),

//       // SingleChildScrollView lets the whole page scroll as ONE unit
//       // (stat card + grid together), instead of the grid scrolling
//       // independently inside a fixed-height Expanded. This is what lets
//       // the stat card visually "sit on top of" the navy AppBar cleanly.
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── STAT CARD ───────────────────────────────────
//             // White, elevated, rounded — replaces the old solid color banner.
//             // This single change is what makes the top of the screen feel
//             // like a proper app instead of a colored strip.
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 18),
//                 decoration: BoxDecoration(
//                   color: AppColors.surface,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.navy.withOpacity(0.08),
//                       blurRadius: 20,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: _StatItem(
//                         icon: Icons.inventory_2_outlined,
//                         value: '${_listings.length}',
//                         label: 'Total',
//                         color: AppColors.navy,
//                       ),
//                     ),
//                     _verticalDivider(),
//                     Expanded(
//                       child: _StatItem(
//                         icon: Icons.check_circle_outline,
//                         value: '$availableCount',
//                         label: 'Available',
//                         color: AppColors.success,
//                       ),
//                     ),
//                     _verticalDivider(),
//                     Expanded(
//                       child: _StatItem(
//                         icon: Icons.access_time,
//                         value: '$rentedCount',
//                         label: 'Rented',
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ── SECTION LABEL ─────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
//               child: Text(
//                 'Your gear',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),

//             // ── LISTINGS GRID ──────────────────────────────────
//             // shrinkWrap + NeverScrollableScrollPhysics because the OUTER
//             // SingleChildScrollView already handles scrolling — without
//             // these two properties, Flutter throws "unbounded height" errors
//             // when a GridView is nested inside another scrollable.
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
//               itemCount: _listings.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 14,
//                 mainAxisSpacing: 14,
//                 childAspectRatio: 0.72,
//               ),
//               itemBuilder: (context, index) {
//                 final item = _listings[index];
//                 return _ListingCard(
//                   item: item,
//                   onEdit: () => Navigator.pushNamed(context, '/edit-item'),
//                   onDelete: () => _confirmDelete(context, item.name),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),

//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Navigator.pushNamed(context, '/add-item'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 3,
//         icon: const Icon(Icons.add),
//         label: const Text(
//           'Add listing',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }

//   Widget _verticalDivider() =>
//       Container(height: 44, width: 1, color: AppColors.border);
// }

// // ─────────────────────────────────────────────────────────────
// // STAT ITEM WIDGET
// // One column inside the stat card: icon + number + label.
// // ─────────────────────────────────────────────────────────────
// class _StatItem extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   final String label;
//   final Color color;

//   const _StatItem({
//     required this.icon,
//     required this.value,
//     required this.label,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: color, size: 22),
//         const SizedBox(height: 6),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // LISTING CARD WIDGET (unchanged structure, only color refs updated)
// // ─────────────────────────────────────────────────────────────
// class _ListingCard extends StatelessWidget {
//   final ListingItem item;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const _ListingCard({
//     required this.item,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.navy.withOpacity(0.06),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             children: [
//               Container(
//                 height: 100,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.08),
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(16),
//                   ),
//                 ),
//                 child: Center(
//                   child: Icon(
//                     item.placeholderIcon,
//                     size: 40,
//                     color: AppColors.primary.withOpacity(0.6),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 3,
//                   ),
//                   decoration: BoxDecoration(
//                     color: item.isAvailable
//                         ? AppColors.success.withOpacity(0.15)
//                         : AppColors.warning.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     item.isAvailable ? 'Available' : 'Rented',
//                     style: TextStyle(
//                       fontSize: 9,
//                       fontWeight: FontWeight.w700,
//                       color: item.isAvailable
//                           ? AppColors.success
//                           : AppColors.warning,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.name,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'Rs. ${item.pricePerDay.toInt()}/day',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.primary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Spacer(),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: onEdit,
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppColors.navy,
//                       side: const BorderSide(color: AppColors.border),
//                       padding: const EdgeInsets.symmetric(vertical: 6),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text('Edit', style: TextStyle(fontSize: 11)),
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: onDelete,
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppColors.error,
//                       side: BorderSide(color: AppColors.error.withOpacity(0.4)),
//                       padding: const EdgeInsets.symmetric(vertical: 6),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text('Delete', style: TextStyle(fontSize: 11)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import '../constants/custom_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────
// DATA MODEL
// Represents a single listing item that the user has posted.
// In Phase 3, this will be a Firestore document with fields like:
// - id: unique document ID from Firebase
// - userId: reference to the owner
// - imageUrl: Firebase Storage URL
// - createdAt: timestamp for sorting
// ─────────────────────────────────────────────────────────────
class ListingItem {
  final String id;
  final String name;
  final String category;
  final double pricePerDay;
  final bool isAvailable;
  final IconData placeholderIcon;
  final int totalRentals;
  final DateTime dateAdded;

  // IMPORTANT: Cannot use 'const' because DateTime.now() is runtime
  // The default value for dateAdded is set in the initializer list
  ListingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerDay,
    required this.isAvailable,
    required this.placeholderIcon,
    this.totalRentals = 0,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();
}

// ─────────────────────────────────────────────────────────────
// MY LISTINGS SCREEN
// StatefulWidget because we'll add filtering/sorting capabilities
// that need to maintain state between rebuilds.
// ─────────────────────────────────────────────────────────────
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  // ── STATE VARIABLES ──────────────────────────────────────
  // Filter: 'all', 'available', 'rented'
  String _filterStatus = 'all';
  // Sort: 'newest', 'oldest', 'price_high', 'price_low'
  String _sortBy = 'newest';
  // View mode: 'grid' or 'list'
  String _viewMode = 'grid';

  // ── STATIC DATA ──────────────────────────────────────────
  // IMPORTANT: Removed 'const' because DateTime values are not compile-time constants
  // Using 'static final' instead - creates the list once when the class is loaded
  static final List<ListingItem> _allListings = [
    ListingItem(
      id: '1',
      name: 'Sony A7III Camera',
      category: 'Cameras',
      pricePerDay: 500,
      isAvailable: true,
      placeholderIcon: Icons.camera_alt_outlined,
      totalRentals: 12,
      dateAdded: DateTime(2026, 6, 28),
    ),
    ListingItem(
      id: '2',
      name: 'JBL Speaker Set',
      category: 'Audio',
      pricePerDay: 200,
      isAvailable: false,
      placeholderIcon: Icons.speaker_outlined,
      totalRentals: 8,
      dateAdded: DateTime(2026, 6, 25),
    ),
    ListingItem(
      id: '3',
      name: 'Power Drill',
      category: 'Tools',
      pricePerDay: 150,
      isAvailable: true,
      placeholderIcon: Icons.construction_outlined,
      totalRentals: 5,
      dateAdded: DateTime(2026, 6, 20),
    ),
    ListingItem(
      id: '4',
      name: 'Acoustic Guitar',
      category: 'Instruments',
      pricePerDay: 300,
      isAvailable: true,
      placeholderIcon: Icons.music_note_outlined,
      totalRentals: 15,
      dateAdded: DateTime(2026, 6, 15),
    ),
    ListingItem(
      id: '5',
      name: '4P Camping Tent',
      category: 'Camping',
      pricePerDay: 350,
      isAvailable: false,
      placeholderIcon: Icons.cabin_outlined,
      totalRentals: 3,
      dateAdded: DateTime(2026, 6, 10),
    ),
    ListingItem(
      id: '6',
      name: 'Football Kit',
      category: 'Sports',
      pricePerDay: 100,
      isAvailable: true,
      placeholderIcon: Icons.sports_soccer_outlined,
      totalRentals: 20,
      dateAdded: DateTime(2026, 6, 5),
    ),
  ];

  // ── GETTER: Filtered & Sorted List ──────────────────────
  // This is a computed property that:
  // 1. Filters items based on status (all/available/rented)
  // 2. Sorts items based on selected sort option
  // 3. Returns a new list - this is efficient for small lists
  //    but for large datasets we'd use a more optimized approach.
  List<ListingItem> get _filteredAndSortedListings {
    // Step 1: Filter by status
    List<ListingItem> filtered = _allListings.where((item) {
      if (_filterStatus == 'all') return true;
      if (_filterStatus == 'available') return item.isAvailable;
      if (_filterStatus == 'rented') return !item.isAvailable;
      return true;
    }).toList();

    // Step 2: Sort the filtered list
    // The sort() method modifies the list in-place, which is fine
    // because we're working with a new list from the filter operation.
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
      default:
        // 'newest' is default, already handled above
        break;
    }

    return filtered;
  }

  // ── DELETE CONFIRMATION DIALOG ──────────────────────────
  // Shows a modal dialog (popup) that asks the user to confirm deletion.
  // ModalRoute (the route that pushed this dialog) handles the overlay.
  // In Phase 3, this will call Firestore's deleteDocument() method.
  void _confirmDelete(BuildContext context, String itemId, String itemName) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents tapping outside to dismiss
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
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          // Cancel button - pops the dialog without doing anything
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          // Delete button - in Phase 3 this will delete from Firestore
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              // TODO Phase 3: Delete from Firestore using itemId
              // Then show a SnackBar confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$itemName" deleted'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── BUILD METHOD ──────────────────────────────────────────
  // The build method is called whenever:
  // 1. Widget is first created
  // 2. setState() is called (filter/sort/view changes)
  // 3. Parent widget rebuilds
  // We keep it clean by extracting widgets into helper methods.
  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredAndSortedListings;
    final availableCount = _allListings.where((l) => l.isAvailable).length;
    final rentedCount = _allListings.where((l) => !l.isAvailable).length;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ── APP BAR ──────────────────────────────────────────
      // CustomAppBar with only view toggle and filter buttons
      // Removed: filter dropdown (now below AppBar) and sort (now below AppBar)
      appBar: CustomAppBar(
        title: 'My Listings',
        actions: [
          // View toggle button (grid ↔ list) - KEPT
          IconButton(
            icon: Icon(
              _viewMode == 'grid'
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
              });
            },
            tooltip: 'Toggle view',
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/my-listings'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),

      // ── BODY ─────────────────────────────────────────────
      // Using SingleChildScrollView to allow the entire page to scroll
      // as one unit (stat card + filter bar + list/grid).
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── STAT CARD ───────────────────────────────────
            // Shows total, available, and rented counts.
            // The white card with shadow creates visual hierarchy
            // and makes the stats stand out from the background.
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
                        value: '${_allListings.length}',
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

            // ── SORT DROPDOWN ──────────────────────────────
            // Added: Sort dropdown below stat card (like Browse screen)
            // This replaces the sort button that was in the AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Sort label
                  const Text(
                    'Sort by:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sort dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        icon: const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
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
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Show count of filtered items
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
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

            // ── FILTER STATUS CHIPS ────────────────────────
            // Shows which filter is currently active.
            // Tapping a chip changes the filter status.
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

            // ── LISTINGS (GRID OR LIST) ────────────────────
            // Conditional rendering based on _viewMode state.
            // Using a switch statement makes it easy to add more views later.
            filteredList.isEmpty
                ? _buildEmptyState()
                : _viewMode == 'grid'
                ? _buildGridView(filteredList)
                : _buildListView(filteredList),
          ],
        ),
      ),

      // ── FLOATING ACTION BUTTON ───────────────────────────
      // Positioned in the bottom-right corner using Scaffold's FAB.
      // The extended version shows both icon and text for better UX.
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

  // ─── FILTER CHIP HELPER ──────────────────────────────────
  // Helper method that builds a filter chip with proper styling.
  // Uses the selected state to change colors and add a checkmark.
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
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
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── GRID VIEW BUILDER ──────────────────────────────────
  // Builds a 2-column grid of listing cards.
  // Uses GridView.builder for efficient on-demand rendering.
  Widget _buildGridView(List<ListingItem> listings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GridView.builder(
        shrinkWrap:
            true, // Important: allows GridView inside SingleChildScrollView
        physics:
            const NeverScrollableScrollPhysics(), // Outer scroll handles it
        itemCount: listings.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final item = listings[index];
          return _ListingCard(
            item: item,
            onEdit: () => Navigator.pushNamed(
              context,
              '/edit-item',
              arguments: {'itemId': item.id}, // Pass ID for editing
            ),
            onDelete: () => _confirmDelete(context, item.id, item.name),
          );
        },
      ),
    );
  }

  // ─── LIST VIEW BUILDER ──────────────────────────────────
  // Builds a vertical list of listing items with more details.
  // Each item takes full width and shows more information.
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
          onDelete: () => _confirmDelete(context, item.id, item.name),
        );
      },
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────
  // Shown when no items match the current filter.
  // Provides helpful messaging and an action button to add items.
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
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _filterStatus == 'all'
                  ? Icons.inbox_rounded
                  : Icons.search_off_rounded,
              size: 40,
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'all'
                ? 'No listings yet'
                : 'No ${_filterStatus} items',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _filterStatus == 'all'
                ? 'Start by adding your first gear listing'
                : 'Try changing the filter to see more items',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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

  // ─── VERTICAL DIVIDER ─────────────────────────────────────
  // Creates a vertical line for separating stat items.
  // Using a Container with fixed height and width.
  Widget _verticalDivider() =>
      Container(height: 44, width: 1, color: AppColors.border);
}

// ─────────────────────────────────────────────────────────────
// STAT ITEM WIDGET
// Displays a single statistic (icon, number, label).
// Reusable component used in the stat card.
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
        // Using RichText or Text with larger font for the number
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
// LISTING CARD (Grid View)
// Shows a listing item in a compact card format.
// Uses Stack for overlaying status badge on the image area.
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
          // ── IMAGE AREA ────────────────────────────────────
          // Uses a Stack to overlay the status badge and rental count
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
              // Status badge (Available/Rented)
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
              // Total rentals badge (shows popularity)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${item.totalRentals} rentals',
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── DETAILS ───────────────────────────────────────
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
                const SizedBox(height: 2),
                Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // ── ACTION BUTTONS ──────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// LISTING LIST ITEM (List View)
// Alternative view mode showing more details in a horizontal layout.
// Used when user toggles to list view for better readability.
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── ICON ──────────────────────────────────────────
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.placeholderIcon,
              size: 28,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 12),
          // ── DETAILS ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
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
                            ? AppColors.success.withOpacity(0.12)
                            : AppColors.warning.withOpacity(0.12),
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
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.totalRentals} rentals',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(item.dateAdded),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── ACTION BUTTONS ──────────────────────────────
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.navy,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Edit',
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
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper to format dates for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }
}
