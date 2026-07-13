import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/custom_app_bar.dart';

// ─────────────────────────────────────────────────────────────
// DATA MODEL
// One Review = one rating left by a renter after using your gear.
// ─────────────────────────────────────────────────────────────
class ReviewItem {
  final String reviewerName;
  final String itemRented;
  final double rating; // out of 5
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

// ─────────────────────────────────────────────────────────────
// RATINGS SCREEN
// StatelessWidget — this screen only DISPLAYS existing reviews,
// nothing on it changes based on user interaction (no filters,
// no editable fields). Phase 3: reviews come from a Firestore
// subcollection under the user's document instead of dummy data.
// ─────────────────────────────────────────────────────────────
class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  static const List<ReviewItem> _reviews = [
    ReviewItem(
      reviewerName: 'Ahmed Khan',
      itemRented: 'Sony A7III Camera',
      rating: 5.0,
      comment: 'Camera was in perfect condition, owner was very responsive!',
      date: '15 Jun 2026',
    ),
    ReviewItem(
      reviewerName: 'Ali Hassan',
      itemRented: 'JBL Speaker Set',
      rating: 4.5,
      comment: 'Great sound quality, minor scuff on the casing.',
      date: '23 Jun 2026',
    ),
    ReviewItem(
      reviewerName: 'Usman Tariq',
      itemRented: 'Power Drill',
      rating: 4.0,
      comment: 'Worked well, pickup process could be faster.',
      date: '28 Jun 2026',
    ),
    ReviewItem(
      reviewerName: 'Hira Ahmad',
      itemRented: 'Acoustic Guitar',
      rating: 5.0,
      comment: 'Beautiful guitar, exactly as described. Highly recommend!',
      date: '2 Jul 2026',
    ),
  ];

  // Computes the average of all ratings — a simple example of using
  // .fold() to sum a list, then dividing by its length.
  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Shared AppBar gives us the automatic back arrow since this
      // screen is reached via Navigator.pushNamed from Profile — no
      // Drawer/BottomNav needed, same reasoning as EditProfileScreen.
      appBar: const CustomAppBar(title: 'Ratings & Reviews'),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AVERAGE RATING SUMMARY CARD ─────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Row of 5 star icons — filled up to the rounded
                    // average, rest shown as outlined stars.
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
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── SECTION LABEL ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                'All Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // ── REVIEW LIST ──────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// REVIEW CARD WIDGET
// One card per review — reviewer name, star rating, comment, date.
// ─────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final ReviewItem review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.06),
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
              // CircleAvatar with initials — avoids needing a real image
              // until Firebase Storage is wired up in Phase 3.
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.navy.withOpacity(0.1),
                    child: Text(
                      review.reviewerName[0], // first letter of name
                      style: const TextStyle(
                        color: AppColors.navy,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Rented: ${review.itemRented}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                review.date,
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Star rating row for THIS specific review
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
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
