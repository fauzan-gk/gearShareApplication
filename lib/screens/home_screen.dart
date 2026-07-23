import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import '../constants/custom_bottom_nav.dart';
import '../constants/shimmer_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _dismissedAccepted = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Cameras', 'icon': Icons.camera_alt_outlined, 'color': 0xFF4A90D9},
    {'name': 'Tools', 'icon': Icons.construction_outlined, 'color': 0xFFE67E22},
    {'name': 'Camping', 'icon': Icons.cabin_outlined, 'color': 0xFF27AE60},
    {
      'name': 'Sports',
      'icon': Icons.sports_soccer_outlined,
      'color': 0xFFE74C3C,
    },
    {'name': 'Music', 'icon': Icons.music_note_outlined, 'color': 0xFF8E44AD},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'GearShare',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/home'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ACCEPTED REQUEST CARD (real-time) ──────────
            if (!_dismissedAccepted)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rentalRequests')
                    .where('renterId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .where('status', isEqualTo: 'approved')
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  final phone = data['ownerPhone'] as String? ?? '';
                  final itemName = data['itemName'] as String? ?? 'an item';
                  final notificationSent = data['notificationSent'] as bool? ?? false;
                  if (phone.isEmpty || notificationSent) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rental Approved!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Contact owner for $itemName at $phone',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _dismissedAccepted = true),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // ── SEARCH BAR ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/browse-search'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceFor(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navyFor(context).withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textSecondaryFor(context)),
                      const SizedBox(width: 10),
                      Text(
                        'Search equipment...',
                        style: TextStyle(
                          color: AppColors.textHintFor(context),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── FEATURED BANNER ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/browse-search'),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, const Color(0xFFD06A00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.elevatedShadow,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20, bottom: -20,
                          child: Icon(Icons.bolt_rounded, size: 140, color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        Positioned(
                          left: 40, top: -30,
                          child: Icon(Icons.explore_rounded, size: 100, color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('🔥', style: TextStyle(fontSize: 11)),
                                    SizedBox(width: 3),
                                    Text('Trending', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Popular Gear Near You', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                              const SizedBox(height: 3),
                              Text('Find the most rented equipment in your area', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Explore Now', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11)),
                                    const SizedBox(width: 3),
                                    Icon(Icons.arrow_forward_ios, size: 9, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            ),

            // ── CATEGORIES ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryFor(context),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/category'),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final color = Color(category['color'] as int);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/browse-search',
                        arguments: {'category': category['name']},
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
                            ),
                            child: Icon(category['icon'] as IconData, color: color, size: 28),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['name'] as String,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondaryFor(context)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // ── FEATURED ITEMS (Horizontal Scroll) ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '⭐ Featured Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryFor(context),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/browse-search'),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Featured Items StreamBuilder
            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('listings')
                    .where('isAvailable', isEqualTo: true)
                    .where('isFeatured', isEqualTo: true)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const FeaturedShimmer();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text('No featured items yet', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        ],
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'Unknown';
                      final price = 'Rs. ${data['price']?.toInt() ?? 0}/day';
                      final owner = data['ownerName'] ?? 'Unknown';
                      final rating = (data['rating'] ?? 0.0).toDouble();
                      final imageUrls = data['imageUrls'] as List<dynamic>? ?? [];
                      final imageUrl = imageUrls.isNotEmpty ? imageUrls.first.toString() : '';
                      final country = data['country'] ?? '';
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        child: _FeaturedItemCard(
                          name: name,
                          price: price,
                          owner: owner,
                          rating: rating,
                          imageUrl: imageUrl,
                          country: country,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/item-detail',
                            arguments: {
                              'listingId': docs[index].id,
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── RECENTLY ADDED ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🔄 Recently Added',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryFor(context),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/browse-search'),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Recently Added StreamBuilder
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .orderBy('createdAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const RecentShimmer();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text('No listings yet', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unknown';
                    final price = 'Rs. ${data['price']?.toInt() ?? 0}/day';
                    final owner = data['ownerName'] ?? 'Unknown';
                    final rating = (data['rating'] ?? 0.0).toDouble();
                    final imageUrls = data['imageUrls'] as List<dynamic>? ?? [];
                    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first.toString() : '';
                    final country = data['country'] ?? '';
                    return _RecentItemCard(
                      name: name,
                      price: price,
                      owner: owner,
                      rating: rating,
                      imageUrl: imageUrl,
                      country: country,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/item-detail',
                        arguments: {
                          'listingId': docs[index].id,
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FEATURED ITEM CARD ──────────────────────────────────────
class _FeaturedItemCard extends StatelessWidget {
  final String name;
  final String price;
  final String owner;
  final double rating;
  final String imageUrl;
  final String country;
  final VoidCallback onTap;

  const _FeaturedItemCard({
    required this.name,
    required this.price,
    required this.owner,
    required this.rating,
    required this.imageUrl,
    required this.country,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  if (imageUrl.isNotEmpty)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const Center(child: Icon(Icons.image_outlined, size: 36, color: Colors.grey)),
                        errorWidget: (_, _, _) => const Center(child: Icon(Icons.image_outlined, size: 36, color: Colors.grey)),
                      ),
                    )
                  else
                    const Center(child: Icon(Icons.image_outlined, size: 36, color: Colors.grey)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 2),
                          Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimaryFor(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('by $owner', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryFor(context))),
                  const SizedBox(height: 4),
                  Text(price, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                  if (country.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.location_on_outlined, size: 10, color: AppColors.textHintFor(context)),
                      const SizedBox(width: 2),
                      Text(country, style: TextStyle(fontSize: 10, color: AppColors.textHintFor(context))),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── RECENT ITEM CARD ────────────────────────────────────────
class _RecentItemCard extends StatelessWidget {
  final String name;
  final String price;
  final String owner;
  final double rating;
  final String imageUrl;
  final String country;
  final VoidCallback onTap;

  const _RecentItemCard({
    required this.name,
    required this.price,
    required this.owner,
    required this.rating,
    required this.imageUrl,
    required this.country,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const Center(child: Icon(Icons.image_outlined, size: 28, color: Colors.grey)),
                      errorWidget: (_, _, _) => const Center(child: Icon(Icons.image_outlined, size: 28, color: Colors.grey)),
                    )
                  : const Center(child: Icon(Icons.image_outlined, size: 28, color: Colors.grey)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimaryFor(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('by $owner', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryFor(context))),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(price, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(width: 10),
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 12, color: AppColors.textSecondaryFor(context))),
                    ]),
                    if (country.isNotEmpty) ...[
                      const Spacer(),
                      Icon(Icons.location_on_outlined, size: 12, color: AppColors.textHintFor(context)),
                      const SizedBox(width: 2),
                      Text(country, style: TextStyle(fontSize: 11, color: AppColors.textHintFor(context))),
                    ],
                  ]),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textHintFor(context)),
          ],
        ),
      ),
    );
  }
}
