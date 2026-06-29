import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────
// DATA MODEL
// A model class is a blueprint that describes what a single
// piece of data looks like. Here, one ListingItem = one gear
// card in the grid.
// In Phase 3 this will come from Firestore — for now it's
// hardcoded "dummy" data so we can build the UI.
// ─────────────────────────────────────────────────────────────
class ListingItem {
  final String name; // e.g. "Sony A7III Camera"
  final String category; // e.g. "Cameras"
  final double pricePerDay; // e.g. 500.0
  final bool isAvailable; // true = green badge, false = yellow badge
  final IconData placeholderIcon; // shown instead of a real image for now

  // 'const' constructor = this object never changes after creation (immutable)
  // 'required' = you MUST pass this field, it can't be null
  const ListingItem({
    required this.name,
    required this.category,
    required this.pricePerDay,
    required this.isAvailable,
    required this.placeholderIcon,
  });
}

// ─────────────────────────────────────────────────────────────
// MAIN SCREEN WIDGET
// StatelessWidget = this screen has NO changing state.
// The list is fixed dummy data, nothing changes on tap.
// When we hook up Firebase later, this becomes StatefulWidget.
// ─────────────────────────────────────────────────────────────
class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  // 'static const' = this list belongs to the CLASS, not to any
  // single instance. It's created once and shared — efficient.
  // 'const List' = the list itself never changes (immutable).
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

  @override
  Widget build(BuildContext context) {
    // .where() filters the list — like a for loop with a condition.
    // .length counts how many passed the filter.
    // We use this for the summary chips at the top.
    final availableCount = _listings.where((l) => l.isAvailable).length;
    final rentedCount = _listings.where((l) => !l.isAvailable).length;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ── APP BAR ───────────────────────────────────────────
      // Orange AppBar keeps the theme consistent with other screens.
      // 'actions' = widgets that appear on the RIGHT side of the AppBar.
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0, // removes the shadow line below AppBar
        centerTitle: true,
        title: const Text(
          'My Listings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          // Item count badge — e.g. "6 items" — top right corner
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                // Semi-transparent white pill behind the text
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_listings.length} items',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),

      // ── BODY ──────────────────────────────────────────────
      // Column stacks widgets vertically (top to bottom).
      // Child 1: orange summary strip (continues the AppBar visually)
      // Child 2: Expanded grid (takes all remaining height)
      body: Column(
        children: [
          // ── SUMMARY STRIP ────────────────────────────────
          // Same orange as the AppBar — makes it look like one unit.
          // Shows how many items are Available vs Rented at a glance.
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Reusable chip widget defined below
                _SummaryChip(
                  label: 'Available',
                  count: availableCount,
                  color: Colors.white, // white pill = stands out
                  textColor: AppColors.primary, // orange text on white
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  label: 'Rented out',
                  count: rentedCount,
                  color: Colors.white.withOpacity(0.25), // subtle pill
                  textColor: Colors.white,
                ),
              ],
            ),
          ),

          // ── LISTINGS GRID ─────────────────────────────────
          // Expanded = takes ALL remaining vertical space after the strip.
          // Without Expanded, the GridView has no height and crashes.
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listings.length,

              // SliverGridDelegateWithFixedCrossAxisCount controls the grid layout:
              // crossAxisCount: 2       → 2 columns
              // crossAxisSpacing: 12    → horizontal gap between cards
              // mainAxisSpacing: 12     → vertical gap between cards
              // childAspectRatio: 0.75  → each card is taller than wide (portrait)
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),

              // itemBuilder is called once per item.
              // 'index' is the current position (0, 1, 2 ...).
              // We pass the item at that index into the card widget.
              itemBuilder: (context, index) {
                return _ListingCard(
                  item: _listings[index],
                  onEdit: () {}, // will navigate to Edit screen in Phase 2
                  onDelete: () {}, // will delete from Firestore in Phase 3
                );
              },
            ),
          ),
        ],
      ),

      // ── FLOATING ACTION BUTTON (FAB) ──────────────────────
      // FAB is the standard Flutter way to show the PRIMARY action
      // on a screen. Here: "Add a new listing".
      // floatingActionButton.extended = icon + label (wider pill shape)
      // The regular FloatingActionButton only shows an icon.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // will navigate to AddItemScreen in Phase 2
        backgroundColor: AppColors.navy, // navy stands out against white bg
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add listing',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SUMMARY CHIP WIDGET
// Extracted into its own widget so we can reuse it for both
// "Available" and "Rented out" without duplicating code.
// The underscore (_) means it's PRIVATE — only usable in this file.
// ─────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color; // background color of the pill
  final Color textColor; // text color inside the pill

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20), // fully rounded pill shape
      ),
      child: Row(
        children: [
          // The count number — bold and larger
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(width: 5),
          // The label text — smaller
          Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LISTING CARD WIDGET
// One card in the grid. Extracted as its own widget because:
// 1. Keeps the GridView's itemBuilder clean (one line, not 80)
// 2. This card could be reused on other screens later
// ─────────────────────────────────────────────────────────────
class _ListingCard extends StatelessWidget {
  final ListingItem item;
  final VoidCallback onEdit; // VoidCallback = a function that takes no
  final VoidCallback onDelete; // arguments and returns nothing → () {}

  const _ListingCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, // white card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2), // shadow goes 2px downward
          ),
        ],
      ),

      // Column stacks: image area → text info → spacer → buttons
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── IMAGE AREA WITH STATUS BADGE ────────────────
          // Stack lets widgets overlap each other.
          // The image placeholder is at the bottom of the stack,
          // and the status badge is positioned on top of it.
          Stack(
            children: [
              // Image placeholder (orange-tinted box + centered icon)
              Container(
                height: 100,
                width: double.infinity, // fills the card's full width
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  // Only round the TOP corners — bottom stays flat
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    item.placeholderIcon,
                    size: 40,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ),

              // Status badge — overlaps the image, top-right corner
              // Positioned works ONLY inside a Stack widget.
              // top: 8, right: 8 = 8px from the top and right edges.
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    // Conditional color — green tint if available, yellow if rented
                    color: item.isAvailable
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    // Conditional text — ternary operator: condition ? ifTrue : ifFalse
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

          // ── ITEM NAME & PRICE ────────────────────────────
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
                  // If name is too long, cut it with "..." instead of overflowing
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${item.pricePerDay.toInt()}/day',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary, // orange price = stands out
                  ),
                ),
              ],
            ),
          ),

          // Spacer pushes the buttons to the BOTTOM of the card.
          // Without this, the buttons would sit right below the price.
          const Spacer(),

          // ── EDIT & DELETE BUTTONS ────────────────────────
          // Row puts two buttons side by side.
          // Each is wrapped in Expanded so they share equal width.
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
                      // Red border — signals a destructive action
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
