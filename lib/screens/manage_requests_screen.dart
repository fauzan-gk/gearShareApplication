import 'package:flutter/material.dart';

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

  // Shows a confirmation dialog before approving/rejecting
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
          title: Text(isApprove ? 'Approve Request?' : 'Reject Request?'),
          content: Text(
            '${isApprove ? 'Approve' : 'Reject'} rental request from ${request['renter']} for ${request['item']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isApprove ? Colors.green : Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context); // close dialog
                _handleRequestDecision(request, isApprove);
              },
              child: Text(
                isApprove ? 'Approve' : 'Reject',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Moves request from pending list to history list
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
        content: Text(isApprove ? 'Request approved' : 'Request rejected'),
        backgroundColor: const Color(0xFF1B2A4A),
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
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A4A),
        title: const Text(
          'Manage Requests',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF4820A),
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFF4820A),
          tabs: [
            Tab(text: 'Pending (${_pendingRequests.length})'),
            const Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending tab
          _pendingRequests.isEmpty
              ? const Center(
                  child: Text(
                    'No pending requests',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pendingRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFF1B2A4A),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request['renter']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        request['item']!,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Color(0xFFF4820A),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  request['dates']!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => _showConfirmDialog(
                                      request: request,
                                      isApprove: false,
                                    ),
                                    child: const Text(
                                      'Reject',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF4820A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => _showConfirmDialog(
                                      request: request,
                                      isApprove: true,
                                    ),
                                    child: const Text(
                                      'Approve',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // History tab
          _historyRequests.isEmpty
              ? const Center(
                  child: Text(
                    'No history yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historyRequests.length,
                  itemBuilder: (context, index) {
                    final request = _historyRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _statusColor(
                            request['status']!,
                          ).withValues(alpha: 0.15),
                          child: Icon(
                            request['status'] == 'approved'
                                ? Icons.check
                                : Icons.close,
                            color: _statusColor(request['status']!),
                          ),
                        ),
                        title: Text(
                          request['renter']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${request['item']} • ${request['dates']}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(
                              request['status']!,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            request['status']!.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(request['status']!),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
