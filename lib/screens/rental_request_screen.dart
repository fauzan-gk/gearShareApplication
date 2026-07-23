import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/image_service.dart';
import '../services/cnic_validator.dart';

class RentalRequestScreen extends StatefulWidget {
  final String itemName;
  final String itemPrice;
  final String ownerId;
  final String listingId;

  const RentalRequestScreen({
    super.key,
    required this.itemName,
    required this.itemPrice,
    required this.ownerId,
    required this.listingId,
  });

  @override
  State<RentalRequestScreen> createState() => _RentalRequestScreenState();
}

class _RentalRequestScreenState extends State<RentalRequestScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _pickupMethod = 'Self Pickup';
  PickedImage? _cnicImage;
  bool _isUploading = false;

  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickCnicImage() async {
    final img = await ImageService.pickSingleImage();
    if (img == null) return;
    final result = await CnicValidator.validateImage(img.bytes);
    if (!mounted) return;
    if (!result.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(result.message ?? 'Invalid CNIC image')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(result.detectedNumber != null
                  ? 'CNIC detected: ${result.detectedNumber}'
                  : 'CNIC verified'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B2A4A),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _cnicImage = img);
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

  Future<bool> _showTermsDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.description_outlined, color: Color(0xFF1B2A4A)),
            SizedBox(width: 8),
            Text('Terms & Conditions'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A4A).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rental Agreement',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'By renting this item, you agree that:\n\n'
                      '1. You will return the item within the agreed rental period.\n'
                      '2. Late returns may result in additional charges.\n'
                      '3. You are responsible for any damage during the rental period.\n'
                      '4. The item must be returned in the same condition as received.\n'
                      '5. You have provided accurate CNIC information for verification.\n'
                      '6. Any disputes will be resolved between owner and renter.\n'
                      '7. You understand that GearShare is a platform only and not '
                      'liable for any disputes.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2A4A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'I Agree',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _submitRequest() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (_cnicImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your CNIC image')),
      );
      return;
    }

    final agreed = await _showTermsDialog();
    if (!agreed || !mounted) return;

    setState(() => _isUploading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      if (uid == widget.ownerId) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot rent your own item')),
        );
        setState(() => _isUploading = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final renterName = userDoc.data()?['name'] as String? ?? 'Unknown';
      final price = double.tryParse(widget.itemPrice) ?? 0;

      String ownerPhone = '';
      if (widget.ownerId.isNotEmpty) {
        final ownerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.ownerId)
            .get();
        ownerPhone = ownerDoc.data()?['phone'] as String? ?? '';
      }

      final cnicUrl = await ImageService.uploadImage(_cnicImage!, uid, 'cnic');

      await FirebaseFirestore.instance.collection('rentalRequests').add({
        'itemName': widget.itemName,
        'itemPrice': widget.itemPrice,
        'listingId': widget.listingId,
        'renterId': uid,
        'renterName': renterName,
        'ownerId': widget.ownerId,
        'ownerPhone': ownerPhone,
        'renterCnicUrl': cnicUrl,
        'totalAmount': price * _totalDays,
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'totalDays': _totalDays,
        'pickupMethod': _pickupMethod,
        'message': _messageController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rental request sent for ${widget.itemName}'),
          backgroundColor: const Color(0xFF1B2A4A),
        ),
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
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
                'CNIC Verification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2A4A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Upload a clear image of your CNIC for identity verification',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickCnicImage,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _cnicImage != null
                          ? const Color(0xFFF4820A)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: _cnicImage != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _cnicImage!.bytes,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => setState(() => _cnicImage = null),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 36,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to upload CNIC',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

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
                  onPressed: _isUploading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4820A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
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
