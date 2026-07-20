import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';

class ReviewItem {
  final String reviewerName;
  final String itemRented;
  final double rating;
  final String comment;
  final String date;

  const ReviewItem({
    required this.reviewerName,
    required this.itemRented,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  List<ReviewItem> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final listingsSnapshot = await FirebaseFirestore.instance
          .collection('listings')
          .where('ownerId', isEqualTo: uid)
          .get();

      List<ReviewItem> allReviews = [];
      for (var listing in listingsSnapshot.docs) {
        final listingName =
            listing['title'] ?? listing['name'] ?? 'Unknown Item';
        final reviewsSnapshot = await FirebaseFirestore.instance
            .collection('listings')
            .doc(listing.id)
            .collection('reviews')
            .get();

        for (var reviewDoc in reviewsSnapshot.docs) {
          allReviews.add(ReviewItem(
            reviewerName: reviewDoc['userName'] ?? 'Anonymous',
            itemRented: listingName,
            rating: (reviewDoc['rating'] ?? 5).toDouble(),
            comment: reviewDoc['comment'] ?? '',
            date: _formatDate(reviewDoc['timestamp']),
          ));
        }
      }

      setState(() {
        _reviews = allReviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return 'Recently';
    final date = (ts as Timestamp).toDate();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<double>(0, (s, r) => s + r.rating);
    return total / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Ratings & Reviews'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceFor(context),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navyFor(context)
                                .withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navyFor(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final filled = index < _averageRating.round();
                              return Icon(
                                filled
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: AppColors.primary,
                                size: 22,
                              );
                            }),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Based on ${_reviews.length} reviews',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryFor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Text(
                      'All Reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: _reviews
                          .map(
                            (review) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ReviewCard(review: review),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewItem review;

  const _ReviewCard({required this.review});

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
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        AppColors.navyFor(context).withValues(alpha: 0.1),
                    child: Text(
                      review.reviewerName[0],
                      style: TextStyle(
                        color: AppColors.navyFor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimaryFor(context),
                        ),
                      ),
                      Text(
                        'Rented: ${review.itemRented}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryFor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                review.date,
                style: TextStyle(
                    fontSize: 11, color: AppColors.textHintFor(context)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              final filled = index < review.rating.round();
              return Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: AppColors.primary,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryFor(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
