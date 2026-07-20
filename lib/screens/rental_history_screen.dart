import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';

class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({super.key});

  @override
  State<RentalHistoryScreen> createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen> {
  String _selectedFilter = 'All Rentals';
  final List<String> _filters = ['All Rentals', 'Active', 'Completed'];
  List<RentalHistoryCard> _allRentals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('rentals')
          .where('renterId', isEqualTo: uid)
          .orderBy('rentalDate', descending: true)
          .get();

      setState(() {
        _allRentals = snapshot.docs.map((doc) {
          final data = doc.data();
          return RentalHistoryCard(
            itemName: data['itemName'] ?? 'Unknown Item',
            renterName: data['renterName'] ?? 'Unknown',
            ownerPhone: data['ownerPhone'] ?? '',
            rentalDate: _formatDate((data['rentalDate'] as Timestamp).toDate()),
            returnDate: _formatDate((data['returnDate'] as Timestamp).toDate()),
            totalAmount: data['totalAmount'] ?? 0,
            isCompleted: data['isCompleted'] ?? false,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  List<RentalHistoryCard> get _filteredRentals {
    if (_selectedFilter == 'All Rentals') return _allRentals;
    final wantsCompleted = _selectedFilter == 'Completed';
    return _allRentals.where((r) => r.isCompleted == wantsCompleted).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Rental History'),
      drawer: const AppDrawer(currentRoute: '/rental-history'),

      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: _filters.map((filter) {
                final isActive = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.surfaceFor(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.borderFor(context),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondaryFor(context),
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

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRentals.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _filteredRentals.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) => _filteredRentals[index],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: AppColors.textHintFor(context),
          ),
          const SizedBox(height: 14),
          Text(
            _isLoading ? 'Loading...' : 'No ${_selectedFilter.toLowerCase()} found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryFor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class RentalHistoryCard extends StatelessWidget {
  final String itemName;
  final String renterName;
  final String ownerPhone;
  final String rentalDate;
  final String returnDate;
  final int totalAmount;
  final bool isCompleted;

  const RentalHistoryCard({
    super.key,
    required this.itemName,
    required this.renterName,
    required this.ownerPhone,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryFor(context),
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
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.15),
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

          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textSecondaryFor(context),
              ),
              const SizedBox(width: 6),
              Text(
                'Renter: ',
                style: TextStyle(color: AppColors.textSecondaryFor(context), fontSize: 13),
              ),
              Text(
                renterName,
                style: TextStyle(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (!isCompleted && ownerPhone.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Owner phone: ',
                  style: TextStyle(color: AppColors.textSecondaryFor(context), fontSize: 13),
                ),
                Text(
                  ownerPhone,
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundFor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateBlock(context, 'Rental Date', rentalDate),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: AppColors.textSecondaryFor(context),
                ),
                _buildDateBlock(context, 'Return Date', returnDate),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: AppColors.borderFor(context), height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Revenue',
                style: TextStyle(
                  color: AppColors.textSecondaryFor(context),
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

  Widget _buildDateBlock(BuildContext context, String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: AppColors.textSecondaryFor(context), fontSize: 11),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: AppColors.textPrimaryFor(context),
            ),
            const SizedBox(width: 4),
            Text(
              date,
              style: TextStyle(
                color: AppColors.textPrimaryFor(context),
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
