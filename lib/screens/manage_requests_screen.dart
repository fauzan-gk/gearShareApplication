import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/custom_app_bar.dart';

class ManageRequestsScreen extends StatefulWidget {
  const ManageRequestsScreen({super.key});

  @override
  State<ManageRequestsScreen> createState() => _ManageRequestsScreenState();
}

class _ManageRequestsScreenState extends State<ManageRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    required DocumentSnapshot doc,
    required bool isApprove,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isApprove ? 'Approve Request?' : 'Reject Request?'),
        content: Text(
          '${isApprove ? 'Approve' : 'Reject'} rental request for ${data['itemName']}?',
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
              Navigator.pop(context);
              _handleDecision(doc.id, isApprove);
            },
            child: Text(
              isApprove ? 'Approve' : 'Reject',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDecision(String docId, bool isApprove) async {
    try {
      await FirebaseFirestore.instance
          .collection('rentalRequests')
          .doc(docId)
          .update({'status': isApprove ? 'approved' : 'rejected'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isApprove ? 'Request approved' : 'Request rejected'),
          backgroundColor: const Color(0xFF1B2A4A),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Manage Requests',
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFF4820A),
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFF4820A),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── PENDING TAB ──────────────────────────────────
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('rentalRequests')
                .where('status', isEqualTo: 'pending')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF4820A)),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No pending requests',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['itemName'] ?? 'Unknown Item',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      data['itemPrice'] ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFFF4820A),
                                        fontWeight: FontWeight.w600,
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
                                '${data['totalDays'] ?? 0} day(s) • ${data['pickupMethod'] ?? ''}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          if ((data['message'] ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Note: ${data['message']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
                                    doc: doc,
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
                                    doc: doc,
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
              );
            },
          ),

          // ── HISTORY TAB ──────────────────────────────────
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('rentalRequests')
                .where('status', whereIn: ['approved', 'rejected'])
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF4820A)),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No history yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'pending';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _statusColor(status).withOpacity(0.15),
                        child: Icon(
                          status == 'approved' ? Icons.check : Icons.close,
                          color: _statusColor(status),
                        ),
                      ),
                      title: Text(
                        data['itemName'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${data['totalDays'] ?? 0} day(s) • ${data['pickupMethod'] ?? ''}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
