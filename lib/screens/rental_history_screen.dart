import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';

// ─────────────────────────────────────────────────────────────
// RENTAL HISTORY SCREEN
// Changed from StatelessWidget to StatefulWidget — the filter chips
// need to remember WHICH one is currently selected, and the list needs
// to actually filter based on that. A StatelessWidget has no way to
// hold or update that kind of changing information.
// ─────────────────────────────────────────────────────────────
class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({super.key});

  @override
  State<RentalHistoryScreen> createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen> {
  // Tracks which filter chip is currently selected.
  String _selectedFilter = 'All Rentals';

  final List<String> _filters = ['All Rentals', 'Active', 'Completed'];

  // Dummy data — in Phase 3 this comes from a Firestore query instead.
  final List<RentalHistoryCard> _allRentals = const [
    RentalHistoryCard(
      itemName: 'Sony A7III Camera',
      renterName: 'Ahmed Khan',
      rentalDate: '12 Jun 2026',
      returnDate: '15 Jun 2026',
      totalAmount: 1500,
      isCompleted: true,
    ),
    RentalHistoryCard(
      itemName: 'JBL Speaker Set',
      renterName: 'Ali Hassan',
      rentalDate: '20 Jun 2026',
      returnDate: '23 Jun 2026',
      totalAmount: 600,
      isCompleted: false,
    ),
    RentalHistoryCard(
      itemName: 'Power Drill',
      renterName: 'Usman Tariq',
      rentalDate: '25 Jun 2026',
      returnDate: '28 Jun 2026',
      totalAmount: 450,
      isCompleted: true,
    ),
  ];

  // Getter — recomputes the filtered list fresh every rebuild.
  // Same pattern used in BrowseSearchScreen and CategoryScreen,
  // so all three "list + filter" screens work identically.
  List<RentalHistoryCard> get _filteredRentals {
    if (_selectedFilter == 'All Rentals') return _allRentals;
    final wantsCompleted = _selectedFilter == 'Completed';
    return _allRentals.where((r) => r.isCompleted == wantsCompleted).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Rental History'),
      drawer: const AppDrawer(currentRoute: '/rental-history'),

      body: Column(
        children: [
          // ── FILTER CHIPS ────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: _filters.map((filter) {
                final isActive = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  // GestureDetector is what makes the chip actually tappable.
                  // The original version had no way to detect a tap at all —
                  // it was just a Container with no gesture handling attached.
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── RENTAL LIST ──────────────────────────────────────
          Expanded(
            child: _filteredRentals.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: _filteredRentals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) => _filteredRentals[index],
                  ),
          ),
        ],
      ),
    );
  }

  // Shown when a filter matches zero rentals (e.g. no "Active" rentals yet).
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 14),
          Text(
            'No ${_selectedFilter.toLowerCase()} found',
            style: const TextStyle(
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
// RENTAL HISTORY CARD WIDGET
// Kept as StatelessWidget — a single card never changes on its own,
// it just displays whatever data it's given.
// ─────────────────────────────────────────────────────────────
class RentalHistoryCard extends StatelessWidget {
  final String itemName;
  final String renterName;
  final String rentalDate;
  final String returnDate;
  final int totalAmount;
  final bool isCompleted;

  const RentalHistoryCard({
    super.key,
    required this.itemName,
    required this.renterName,
    required this.rentalDate,
    required this.returnDate,
    required this.totalAmount,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        // Shadow only — no border. Matches the "pick one separation
        // method, not both" fix applied to the other screens.
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
          // Row 1: Item Title & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  // Using the centralized status colors instead of raw
                  // Colors.green / Colors.orange — keeps this card in
                  // sync if the palette ever changes.
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Active',
                  style: TextStyle(
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Renter Details
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              const Text(
                'Renter: ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Text(
                renterName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: Visual Rental Timeline
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateBlock('Rental Date', rentalDate),
                const Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                _buildDateBlock('Return Date', returnDate),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          // Row 4: Pricing Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Revenue',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                'Rs. $totalAmount',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Inner Date Element Helper
  Widget _buildDateBlock(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              date,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
