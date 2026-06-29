import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RentalHistoryScreen extends StatelessWidget {
  const RentalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── APP BAR ───────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Rental History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),

      body: Column(
        children: [
          // ── FILTER CHIPS TAB BAR ───────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All Rentals', isActive: true),
                const SizedBox(width: 8),
                _buildFilterChip('Active', isActive: false),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', isActive: false),
              ],
            ),
          ),

          // ── RENTAL LIST ─────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: const [
                RentalHistoryCard(
                  itemName: 'Sony A7III Camera',
                  renterName: 'Ahmed Khan',
                  rentalDate: '12 Jun 2026',
                  returnDate: '15 Jun 2026',
                  totalAmount: 1500,
                  isCompleted: true,
                ),
                SizedBox(height: 14),
                RentalHistoryCard(
                  itemName: 'JBL Speaker Set',
                  renterName: 'Ali Hassan',
                  rentalDate: '20 Jun 2026',
                  returnDate: '23 Jun 2026',
                  totalAmount: 600,
                  isCompleted: false,
                ),
                SizedBox(height: 14),
                RentalHistoryCard(
                  itemName: 'Power Drill',
                  renterName: 'Usman Tariq',
                  rentalDate: '25 Jun 2026',
                  returnDate: '28 Jun 2026',
                  totalAmount: 450,
                  isCompleted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Filter Chip Helper Widget
  Widget _buildFilterChip(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

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
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  color: isCompleted
                      ? Colors.green.withOpacity(0.12)
                      : Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Active',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Renter Details Layout Block
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
              color: AppColors.background.withOpacity(0.5),
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

          // Row 4: Pricing Summary Footnote
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
