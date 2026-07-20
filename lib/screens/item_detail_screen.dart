import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemDetailScreen extends StatefulWidget {
  final String listingId;

  const ItemDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _reviewController = TextEditingController();
  int _userRating = 0;

  String _itemName = '';
  String _itemPrice = '';
  String _itemDescription = '';
  String _itemCategory = '';
  List<String> _imageUrls = [];
  int _currentImageIndex = 0;
  String _itemLocation = '';
  String _ownerName = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItem();
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _itemName = data['title'] ?? data['name'] ?? 'Unknown Item';
          _itemPrice = data['price'].toString();
          _itemDescription = data['description'] ?? '';
          _itemCategory = data['category'] ?? '';
          final urls = data['imageUrls'];
          if (urls is List && urls.isNotEmpty) {
            _imageUrls = urls.map((e) => e.toString()).toList();
          } else {
            final single = data['imageUrl'] ?? data['image'] ?? '';
            _imageUrls = single.toString().isNotEmpty ? [single.toString()] : [];
          }
          _itemLocation = data['location'] ?? 'Unknown';
          _ownerName = data['ownerName'] ?? 'Unknown';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();
      setState(() {
        _reviews = snapshot.docs.map((doc) => {
              'name': doc['userName'] ?? 'Anonymous',
              'rating': doc['rating'] ?? 5,
              'date': _formatTimestamp(doc['timestamp']),
              'comment': doc['comment'] ?? '',
            }).toList();
      });
    } catch (e) {
      // Reviews are optional; silently fail
    }
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return 'Recently';
    final date = (ts as Timestamp).toDate();
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }

  Future<void> _addReview() async {
    if (_reviewController.text.trim().isEmpty || _userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a rating and review'),
          backgroundColor: Color(0xFF1B2A4A),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId)
          .collection('reviews')
          .add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'userName':
            FirebaseAuth.instance.currentUser!.displayName ?? 'Anonymous',
        'rating': _userRating,
        'comment': _reviewController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _reviewController.clear();
      setState(() => _userRating = 0);
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review added successfully!'),
            backgroundColor: Color(0xFF1B2A4A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add review. Please try again.'),
            backgroundColor: Color(0xFF1B2A4A),
          ),
        );
      }
    }
  }

  String _formatPrice(String price) {
    String cleanPrice = price.replaceAll('Rs.', '').trim();
    if (cleanPrice.contains('/day')) {
      return 'Rs. $cleanPrice';
    }
    return 'Rs. $cleanPrice / day';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFF4820A),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1B2A4A),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1B2A4A), const Color(0xFF243660)],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_imageUrls.isNotEmpty)
                      _imageUrls.length > 1
                          ? PageView.builder(
                              itemCount: _imageUrls.length,
                              onPageChanged: (index) =>
                                  setState(() => _currentImageIndex = index),
                              itemBuilder: (context, index) => Image.network(
                                _imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _buildImagePlaceholder(),
                              ),
                            )
                          : Image.network(
                              _imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _buildImagePlaceholder(),
                            )
                    else
                      _buildImagePlaceholder(),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF1B2A4A).withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_imageUrls.length > 1)
                      Positioned(
                        bottom: 68,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _imageUrls.length,
                            (index) => Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentImageIndex == index ? 10 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: const [],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _itemName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2A4A),
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4820A).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatPrice(_itemPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF4820A),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_itemCategory.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              size: 16,
                              color: Color(0xFF1B2A4A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _itemCategory,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1B2A4A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _itemLocation,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      ...List.generate(5, (index) {
                        return const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 12),
                      const Text(
                        '4.5',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2A4A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${_reviews.length} reviews)',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF4820A,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thumb_up_outlined,
                              size: 14,
                              color: Color(0xFFF4820A),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '98%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF4820A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A4A),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _ownerName.isNotEmpty
                                ? _ownerName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _ownerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF1B2A4A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.verified_outlined,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified Owner',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Member since 2024',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFFF4820A),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFFF4820A),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Description'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '📝 Description',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1B2A4A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _itemDescription.isNotEmpty
                                        ? _itemDescription
                                        : 'No description provided.',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      height: 1.6,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📦 What\'s Included',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1B2A4A),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Column(
                                    children: [
                                      _IncludedItem(
                                        icon: Icons.camera_alt_outlined,
                                        text: 'Camera body with lens',
                                      ),
                                      _IncludedItem(
                                        icon: Icons
                                            .battery_charging_full_outlined,
                                        text: '2x Original batteries',
                                      ),
                                      _IncludedItem(
                                        icon: Icons.charging_station_outlined,
                                        text: 'Charger & USB cable',
                                      ),
                                      _IncludedItem(
                                        icon: Icons.sd_storage_outlined,
                                        text: '64GB Memory card',
                                      ),
                                      _IncludedItem(
                                        icon: Icons.backpack_outlined,
                                        text: 'Carry case with strap',
                                      ),
                                      _IncludedItem(
                                        icon: Icons.cleaning_services_outlined,
                                        text: 'Cleaning kit',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF4820A,
                                ).withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFF4820A,
                                  ).withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Color(0xFFF4820A),
                                    size: 18,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Free delivery within 5km • Insurance available • Security deposit required',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1B2A4A),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          Expanded(
                            child: _reviews.isEmpty
                                ? Center(
                                    child: Text(
                                      'No reviews yet',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: _reviews.length,
                                    itemBuilder: (context, index) {
                                      final review = _reviews[index];
                                      return Column(
                                        children: [
                                          _ReviewTile(
                                            name: review['name'],
                                            rating: review['rating'],
                                            date: review['date'],
                                            comment: review['comment'],
                                          ),
                                          if (index < _reviews.length - 1)
                                            Divider(
                                              color: Colors.grey[200],
                                              height: 24,
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    '💬 Add Your Review',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1B2A4A),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Your Rating:',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ...List.generate(5, (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _userRating = index + 1;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            child: Icon(
                                              index < _userRating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 28,
                                            ),
                                          ),
                                        );
                                      }),
                                      if (_userRating > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          child: Text(
                                            '$_userRating/5',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFF4820A),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _reviewController,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Write your review...',
                                            hintStyle: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 13,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            enabledBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            focusedBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFF4820A),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4820A),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: IconButton(
                                          onPressed: _addReview,
                                          icon: const Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 48,
                                            minHeight: 48,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4820A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Per Day',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      _formatPrice(_itemPrice),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF4820A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/rental-request',
                        arguments: {
                          'itemName': _itemName,
                          'itemPrice': _itemPrice,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4820A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Request to Rent',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildImagePlaceholder() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.image_outlined,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _IncludedItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IncludedItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFF4820A)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final int rating;
  final String date;
  final String comment;

  const _ReviewTile({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF4820A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFFF4820A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1B2A4A),
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        );
                      }),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 46),
          child: Text(
            comment,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
