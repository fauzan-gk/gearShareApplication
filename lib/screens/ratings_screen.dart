import 'package:flutter/material.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  int selectedChip = 0;

  final List<String> chips = ["All", "Recent", "Verified", "5 ★"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xffF4820A),
        icon: const Icon(Icons.rate_review, color: Colors.white),
        label: const Text(
          "Write Review",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {},
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 20),
            _ratingCard(),
            const SizedBox(height: 20),

            // ── Stat cards ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _statCard("128", "Reviews", Icons.comment)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard("95%", "Response", Icons.flash_on)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard("2 hrs", "Reply", Icons.schedule)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ── Rating distribution ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Rating Distribution",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ratingBar("5", 0.92, 96),
                  _ratingBar("4", 0.72, 21),
                  _ratingBar("3", 0.42, 8),
                  _ratingBar("2", 0.18, 2),
                  _ratingBar("1", 0.05, 1),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ── Search box ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search reviews...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xffF4820A),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Filter chips ──
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  final selected = selectedChip == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(chips[index]),
                      selected: selected,
                      selectedColor: const Color(0xffF4820A),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => selectedChip = index),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // ── Section title ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Customer Reviews",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ── Review cards ──
            _reviewCard(
              name: "Ali Ahmed",
              rating: 5,
              date: "2 days ago",
              review:
                  "Excellent experience! The DSLR camera was in perfect condition and exactly as described. The owner was very cooperative and responsive.",
              helpful: 18,
              verified: true,
            ),
            _reviewCard(
              name: "Sarah Khan",
              rating: 4,
              date: "1 week ago",
              review:
                  "The camping equipment was clean and well maintained. Pickup was smooth and communication was great.",
              helpful: 11,
              verified: true,
            ),
            _reviewCard(
              name: "Hamza Ali",
              rating: 5,
              date: "2 weeks ago",
              review:
                  "Amazing GearShare experience. Everything worked perfectly and I would definitely rent again.",
              helpful: 7,
              verified: false,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════
  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffF4820A), Color(0xffFFB347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Ratings & Reviews",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.star, color: Colors.white),
                ],
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: Text(
                  "UF",
                  style: TextStyle(
                    color: Color(0xffF4820A),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      "Top Rated Owner",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════
  //  OVERALL RATING CARD
  // ════════════════════════════════════════
  Widget _ratingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Overall Rating",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const Text(
            "4.8",
            style: TextStyle(
              fontSize: 55,
              color: Color(0xffF4820A),
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => const Icon(Icons.star, color: Colors.amber),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Excellent • 128 Reviews",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  //  STAT CARD
  // ════════════════════════════════════════
  Widget _statCard(String value, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xffF4820A), size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xffF4820A),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  //  RATING BAR
  // ════════════════════════════════════════
  Widget _ratingBar(String star, double value, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              star,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(Color(0xffF4820A)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 35,
            child: Text(
              "$count",
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  //  REVIEW CARD
  // ════════════════════════════════════════
  Widget _reviewCard({
    required String name,
    required int rating,
    required String date,
    required String review,
    required int helpful,
    required bool verified,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info row
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xffF4820A),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (verified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Verified",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Review text
          Text(
            review,
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),

          const SizedBox(height: 18),

          // Photo placeholders
          Row(
            children: List.generate(
              3,
              (_) => Container(
                margin: const EdgeInsets.only(right: 8),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.image, color: Color(0xffF4820A)),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Owner reply
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.reply, color: Color(0xffF4820A)),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Owner Reply",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Thank you for your valuable feedback! We're glad you enjoyed your GearShare experience and hope to see you again soon.",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Helpful & favourite row
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Text(
                "$helpful Helpful",
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.favorite_border, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}
