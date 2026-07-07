// import 'package:flutter/material.dart';
// import '../constants/app_colors.dart';
// import '../constants/custom_app_bar.dart';
// import '../constants/app_drawer.dart';
// import '../constants/custom_bottom_nav.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // Dummy categories for now — will come from Firestore later
//   final List<String> _categories = [
//     'Cameras',
//     'Tools',
//     'Camping',
//     'Sports',
//     'Music',
//   ];

//   // Dummy items for now — will come from Firestore later
//   final List<Map<String, String>> _items = [
//     {'name': 'DSLR Camera', 'price': 'Rs. 800/day'},
//     {'name': 'Power Drill', 'price': 'Rs. 300/day'},
//     {'name': 'Camping Tent', 'price': 'Rs. 500/day'},
//     {'name': 'Mountain Bike', 'price': 'Rs. 400/day'},
//     {'name': 'Projector', 'price': 'Rs. 700/day'},
//     {'name': 'Guitar', 'price': 'Rs. 350/day'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,

//       // Shared AppBar/Drawer/BottomNav — same three components every
//       // other screen uses now. The old HomeScreen was building its own
//       // BottomNavigationBar from scratch with duplicated switch-case
//       // navigation logic instead of reusing CustomBottomNav, which is
//       // exactly the kind of inconsistency we've been fixing everywhere.
//       appBar: CustomAppBar(
//         title: 'GearShare',
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined, color: Colors.white),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       drawer: const AppDrawer(currentRoute: '/home'),
//       bottomNavigationBar: const CustomBottomNav(currentIndex: 0),

//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── SEARCH BAR ──────────────────────────────────
//             // Same floating white card style used on Browse/Category —
//             // now it's tappable and actually takes you to the real
//             // search screen, instead of just sitting there doing nothing.
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//               child: InkWell(
//                 onTap: () => Navigator.pushNamed(context, '/browse-search'),
//                 borderRadius: BorderRadius.circular(16),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 14,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.surface,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColors.navy.withOpacity(0.08),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.search, color: AppColors.textSecondary),
//                       const SizedBox(width: 10),
//                       Text(
//                         'Search equipment...',
//                         style: TextStyle(
//                           color: AppColors.textHint,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // ── CATEGORIES ───────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
//               child: Text(
//                 'Categories',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 40,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: _categories.length,
//                 itemBuilder: (context, index) {
//                   final category = _categories[index];
//                   // Made tappable + wired into the same "Passing Data
//                   // Between Screens" pattern used on CategoryScreen —
//                   // tapping a chip here pre-filters the Browse screen.
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 10),
//                     child: GestureDetector(
//                       onTap: () => Navigator.pushNamed(
//                         context,
//                         '/browse-search',
//                         arguments: {'category': category},
//                       ),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Center(
//                           child: Text(
//                             category,
//                             style: TextStyle(
//                               color: AppColors.primary,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 24),

//             // ── AVAILABLE ITEMS ──────────────────────────────
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 'Available Near You',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             // shrinkWrap + NeverScrollableScrollPhysics because the OUTER
//             // SingleChildScrollView already handles scrolling — same
//             // pattern used on every other screen with a nested grid.
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: _items.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 14,
//                   mainAxisSpacing: 14,
//                   childAspectRatio: 0.8,
//                 ),
//                 itemBuilder: (context, index) {
//                   final item = _items[index];
//                   return _HomeItemCard(
//                     name: item['name']!,
//                     price: item['price']!,
//                     onTap: () => Navigator.pushNamed(
//                       context,
//                       '/item-detail',
//                       arguments: {
//                         'itemName': item['name']!,
//                         'itemPrice': item['price']!,
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // HOME ITEM CARD WIDGET
// // Extracted into its own widget (instead of an inline Card +
// // InkWell in the itemBuilder) so the grid's build method stays
// // readable, and so this card uses the SAME shadow-based container
// // style as _GearCard on Browse and _ListingCard on My Listings —
// // NOT Flutter's default Card/elevation, which looked visually
// // different from the rest of the app.
// // ─────────────────────────────────────────────────────────────
// class _HomeItemCard extends StatelessWidget {
//   final String name;
//   final String price;
//   final VoidCallback onTap;

//   const _HomeItemCard({
//     required this.name,
//     required this.price,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.navy.withOpacity(0.06),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.image_outlined,
//                   color: AppColors.primary.withOpacity(0.5),
//                   size: 40,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               name,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 3),
//             Text(
//               price,
//               style: const TextStyle(
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';
import '../constants/app_drawer.dart';
import '../constants/custom_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dummy categories for now — will come from Firestore later
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

  // Dummy items for now — will come from Firestore later
  final List<Map<String, dynamic>> _featuredItems = [
    {
      'name': 'DSLR Camera',
      'price': 'Rs. 800/day',
      'owner': 'Ahmed',
      'rating': 4.9,
    },
    {
      'name': 'Power Drill',
      'price': 'Rs. 300/day',
      'owner': 'Sara',
      'rating': 4.7,
    },
    {
      'name': 'Camping Tent',
      'price': 'Rs. 500/day',
      'owner': 'Ali',
      'rating': 4.8,
    },
  ];

  final List<Map<String, dynamic>> _recentItems = [
    {
      'name': 'Mountain Bike',
      'price': 'Rs. 400/day',
      'owner': 'Usman',
      'rating': 4.5,
    },
    {
      'name': 'Projector',
      'price': 'Rs. 700/day',
      'owner': 'Fatima',
      'rating': 4.6,
    },
    {'name': 'Guitar', 'price': 'Rs. 350/day', 'owner': 'Hira', 'rating': 4.8},
    {'name': 'Drone', 'price': 'Rs. 1200/day', 'owner': 'Omar', 'rating': 4.9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        'Search equipment...',
                        style: TextStyle(
                          color: AppColors.textHint,
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
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.navy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Decorative background elements
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(
                        Icons.bolt_rounded,
                        size: 100,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Positioned(
                      left: 30,
                      top: -20,
                      child: Icon(
                        Icons.explore_rounded,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '🔥 Trending',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Popular Gear Near You',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find the most rented equipment in your area',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View All →',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
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
              ),
            ),

            // ── CATEGORIES (Horizontal Scroll with Icons) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final color = Color(category['color'] as int);
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/browse-search',
                        arguments: {'category': category['name']},
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: color.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              category['icon'] as IconData,
                              color: color,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category['name'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
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
                  const Text(
                    '⭐ Featured Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _featuredItems.length,
                itemBuilder: (context, index) {
                  final item = _featuredItems[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: _FeaturedItemCard(
                      name: item['name'] as String,
                      price: item['price'] as String,
                      owner: item['owner'] as String,
                      rating: item['rating'] as double,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/item-detail',
                        arguments: {
                          'itemName': item['name'] as String,
                          'itemPrice': item['price'] as String,
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── RECENTLY ADDED (Vertical List) ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🔄 Recently Added',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _recentItems.length,
              itemBuilder: (context, index) {
                final item = _recentItems[index];
                return _RecentItemCard(
                  name: item['name'] as String,
                  price: item['price'] as String,
                  owner: item['owner'] as String,
                  rating: item['rating'] as double,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/item-detail',
                    arguments: {
                      'itemName': item['name'] as String,
                      'itemPrice': item['price'] as String,
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FEATURED ITEM CARD (Horizontal) ────────────────────────
class _FeaturedItemCard extends StatelessWidget {
  final String name;
  final String price;
  final String owner;
  final double rating;
  final VoidCallback onTap;

  const _FeaturedItemCard({
    required this.name,
    required this.price,
    required this.owner,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by $owner',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── RECENT ITEM CARD (List Style) ──────────────────────────
class _RecentItemCard extends StatelessWidget {
  final String name;
  final String price;
  final String owner;
  final double rating;
  final VoidCallback onTap;

  const _RecentItemCard({
    required this.name,
    required this.price,
    required this.owner,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.image_outlined,
                size: 28,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by $owner',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
