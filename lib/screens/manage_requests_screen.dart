import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';

class ManageRequestsScreen extends StatefulWidget {
  const ManageRequestsScreen({super.key});

  @override
  State<ManageRequestsScreen> createState() => _ManageRequestsScreenState();
}

class _ManageRequestsScreenState extends State<ManageRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data — will come from Firestore later
  final List<Map<String, String>> _pendingRequests = [
    {
      'renter': 'Ali Raza',
      'item': 'DSLR Camera',
      'dates': '12 Jul - 15 Jul',
      'status': 'pending',
    },
    {
      'renter': 'Sara Ahmed',
      'item': 'Camping Tent',
      'dates': '20 Jul - 22 Jul',
      'status': 'pending',
    },
  ];

  final List<Map<String, String>> _historyRequests = [
    {
      'renter': 'Bilal Khan',
      'item': 'Power Drill',
      'dates': '1 Jun - 3 Jun',
      'status': 'approved',
    },
    {
      'renter': 'Hina Malik',
      'item': 'Projector',
      'dates': '5 Jun - 6 Jun',
      'status': 'rejected',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showConfirmDialog({
    required Map<String, String> request,
    required bool isApprove,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isApprove ? 'Approve Request?' : 'Reject Request?',
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '${isApprove ? 'Approve' : 'Reject'} rental request from ${request['renter']} for ${request['item']}?',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isApprove ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                _handleRequestDecision(request, isApprove);
              },
              child: Text(
                isApprove ? 'Approve' : 'Reject',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleRequestDecision(Map<String, String> request, bool isApprove) {
    setState(() {
      _pendingRequests.remove(request);
      _historyRequests.insert(0, {
        ...request,
        'status': isApprove ? 'approved' : 'rejected',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isApprove ? '✅ Request approved' : '❌ Request rejected'),
        backgroundColor: AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green.withValues(alpha: 0.08);
      case 'rejected':
        return Colors.red.withValues(alpha: 0.08);
      default:
        return AppColors.primary.withValues(alpha: 0.08);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Manage Requests'),
      drawer: const AppDrawer(currentRoute: '/manage-requests'),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildPendingTab(), _buildHistoryTab()],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB BAR ────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: [
          Tab(text: 'Pending (${_pendingRequests.length})'),
          const Tab(text: 'History'),
        ],
      ),
    );
  }

  // ── PENDING TAB ────────────────────────────────────────────
  Widget _buildPendingTab() {
    if (_pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            const Text(
              'No pending requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All requests have been reviewed',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        return _buildRequestCard(request, isPending: true);
      },
    );
  }

  // ── HISTORY TAB ────────────────────────────────────────────
  Widget _buildHistoryTab() {
    if (_historyRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            const Text(
              'No history yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed requests will appear here',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: _historyRequests.length,
      itemBuilder: (context, index) {
        final request = _historyRequests[index];
        return _buildRequestCard(request, isPending: false);
      },
    );
  }

  // ── REQUEST CARD ──────────────────────────────────────────
  Widget _buildRequestCard(
    Map<String, String> request, {
    required bool isPending,
  }) {
    final status = request['status']!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    request['renter']![0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['renter']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      request['item']!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBgColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  request['dates']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () =>
                        _showConfirmDialog(request: request, isApprove: false),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () =>
                        _showConfirmDialog(request: request, isApprove: true),
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
