import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentalRequestScreen extends StatefulWidget {
  final String itemName;
  final String itemPrice;

  const RentalRequestScreen({
    super.key,
    required this.itemName,
    required this.itemPrice,
  });

  @override
  State<RentalRequestScreen> createState() => _RentalRequestScreenState();
}

class _RentalRequestScreenState extends State<RentalRequestScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _pickupMethod = 'Self Pickup'; // default selected radio option

  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Opens a calendar picker and stores the chosen date
  Future<void> _pickDate({required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF4820A), // header color
              onPrimary: Colors.white,
              onSurface: Color(0xFF1B2A4A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Calculates number of days between start and end date
  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _submitRequest() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('rentalRequests').add({
        'itemName': widget.itemName,
        'itemPrice': widget.itemPrice,
        'renterId': uid,
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'totalDays': _totalDays,
        'pickupMethod': _pickupMethod,
        'message': _messageController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rental request sent for ${widget.itemName}'),
          backgroundColor: const Color(0xFF1B2A4A),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.popUntil(context, (route) => route.settings.name == '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A4A),
        title: const Text(
          'Rental Request',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item summary card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.itemName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.itemPrice,
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
              ),

              const SizedBox(height: 24),

              const Text(
                'Select Rental Dates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2A4A),
                ),
              ),
              const SizedBox(height: 12),

              // Start and end date pickers side by side
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(isStartDate: true),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Date',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Color(0xFFF4820A),
                                ),
                                const SizedBox(width: 6),
                                Text(_formatDate(_startDate)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(isStartDate: false),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End Date',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Color(0xFFF4820A),
                                ),
                                const SizedBox(width: 6),
                                Text(_formatDate(_endDate)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_totalDays > 0) ...[
                const SizedBox(height: 10),
                Text(
                  'Total: $_totalDays day(s)',
                  style: const TextStyle(
                    color: Color(0xFF1B2A4A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              const Text(
                'Pickup Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2A4A),
                ),
              ),

              // Radio buttons for pickup method
              RadioGroup<String>(
                groupValue: _pickupMethod,
                onChanged: (value) {
                  setState(() {
                    _pickupMethod = value!;
                  });
                },
                child: Column(
                  children: [
                    const RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      activeColor: Color(0xFFF4820A),
                      title: Text('Self Pickup'),
                      value: 'Self Pickup',
                    ),
                    const RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      activeColor: Color(0xFFF4820A),
                      title: Text('Delivery (extra charges may apply)'),
                      value: 'Delivery',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Message to Owner (optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2A4A),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any special instructions...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4820A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Send Rental Request',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
