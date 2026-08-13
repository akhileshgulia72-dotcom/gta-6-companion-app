import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Map<String, String> property;

  const PropertyDetailsScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailsScreen> createState() =>
      _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState
    extends State<PropertyDetailsScreen> {
  bool isFavorite = false;
  @override
void initState() {
  super.initState();
  _loadFavorite();
}

Future<void> _loadFavorite() async {
  final prefs = await SharedPreferences.getInstance();

  final name = widget.property['name'] ?? '';

  if (!mounted) return;

  setState(() {
    isFavorite = prefs.getBool('favorite_$name') ?? false;
  });
}

Future<void> _toggleFavorite() async {
  final prefs = await SharedPreferences.getInstance();

  final name = widget.property['name'] ?? '';

  final newValue = !isFavorite;

  await prefs.setBool(
    'favorite_$name',
    newValue,
  );

  if (!mounted) return;

  setState(() {
    isFavorite = newValue;
  });
}

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            foregroundColor: Colors.white,

            actions: [
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite
                      ? const Color(0xFFFF4DA6)
                      : Colors.white,
                ),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                 Image.asset(
  property['image'] ?? 'assets/images/beach_villa.png',
  fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF1B1B1B),
                        child: const Icon(
                          Icons.home_work,
                          color: Colors.white24,
                          size: 80,
                        ),
                      );
                    },
                  ),

                  // Dark gradient
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 25,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _statusBadge(
                          property['status'] ?? 'Concept',
                        ),

                        const SizedBox(height: 10),

                        Text(
                          property['name'] ?? 'Property',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF00D4FF),
                              size: 17,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                property['location'] ??
                                    'Unknown',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              40,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Price
                  _priceCard(
                    property['price'] ?? 'Unknown',
                  ),

                  const SizedBox(height: 22),

                  // Overview
                  _sectionTitle(
                    'PROPERTY OVERVIEW',
                    Icons.info_outline,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    property['description'] ??
                        'No description available.',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Information
                  _sectionTitle(
                    'PROPERTY INFORMATION',
                    Icons.home_work_outlined,
                  ),

                  const SizedBox(height: 12),

                  _infoRow(
                    Icons.category_outlined,
                    'Property Type',
                    property['type'] ?? 'Unknown',
                  ),

                  _infoRow(
                    Icons.king_bed_outlined,
                    'Bedrooms',
                    property['bedrooms'] ?? 'Unknown',
                  ),

                  _infoRow(
                    Icons.bathtub_outlined,
                    'Bathrooms',
                    property['bathrooms'] ?? 'Unknown',
                  ),

                  _infoRow(
                    Icons.directions_car_outlined,
                    'Garage',
                    property['garage'] ?? 'Unknown',
                  ),

                  _infoRow(
                    Icons.pool_outlined,
                    'Pool',
                    property['pool'] ?? 'Unknown',
                  ),

                  _infoRow(
                    Icons.security_outlined,
                    'Security',
                    property['security'] ?? 'Unknown',
                  ),

                  _infoRow(
                    Icons.lock_outline,
                    'Privacy',
                    property['privacy'] ?? 'Unknown',
                  ),

                  _infoRow(
                    Icons.star_outline,
                    'Best For',
                    property['bestFor'] ?? 'Unknown',
                  ),

                  const SizedBox(height: 25),

                  // Features
                  _sectionTitle(
                    'PROPERTY FEATURES',
                    Icons.auto_awesome,
                  ),

                  const SizedBox(height: 12),

                  _featuresCard(
                    property['features'] ?? '',
                  ),

                  const SizedBox(height: 25),

                  // Rating
                  _sectionTitle(
                    'PROPERTY RATINGS',
                    Icons.star,
                  ),

                  const SizedBox(height: 12),

                  _ratingCard(property),

                  const SizedBox(height: 25),

                  // Map button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showComingSoon(
                          context,
                          'Interactive property map is coming soon.',
                        );
                      },
                      icon: const Icon(
                        Icons.location_on,
                      ),
                      label: Text(
                        'VIEW ON MAP',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF00D4FF),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Favorite button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                     onPressed: _toggleFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      label: Text(
                        isFavorite
                            ? 'SAVED TO FAVORITES'
                            : 'ADD TO FAVORITES',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 19,
                          letterSpacing: 1,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFFFF4DA6),
                        side: const BorderSide(
                          color: Color(0xFFFF4DA6),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(
                        alpha: 0.06,
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.blue.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.lightBlueAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This property is presented as a '
                            'GTA 6 Companion concept. '
                            'Information marked as Concept or '
                            'Unknown should not be considered '
                            'official Rockstar Games information.',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.lightBlueAccent.withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Text(
        '🔵 ${status.toUpperCase()}',
        style: GoogleFonts.poppins(
          color: Colors.lightBlueAccent,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _priceCard(String price) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF4DA6).withValues(alpha: 0.15),
            const Color(0xFF00D4FF).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.attach_money,
            color: Color(0xFFFF4DA6),
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'PROPERTY VALUE',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  price,
                  style: GoogleFonts.bebasNeue(
                    color: const Color(0xFFFF4DA6),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF00D4FF),
          size: 21,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.bebasNeue(
            color: const Color(0xFFFF4DA6),
            fontSize: 23,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF00D4FF),
            size: 21,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuresCard(String features) {
    final featureList = features
        .split('•')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: featureList.map((feature) {
          return Padding(
            padding:
                const EdgeInsets.only(bottom: 11),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00D4FF),
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    feature,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _ratingCard(
    Map<String, String> property,
  ) {
    final type = property['type'] ?? '';

    double luxury = 4.5;
    double location = 4.5;
    double privacy = 4.0;
    double entertainment = 4.0;

    if (type == 'Penthouse') {
      luxury = 5.0;
      location = 5.0;
      privacy = 4.8;
      entertainment = 5.0;
    } else if (type == 'Villa') {
      luxury = 4.8;
      location = 5.0;
      privacy = 4.5;
      entertainment = 4.8;
    } else if (type == 'Mansion') {
      luxury = 5.0;
      location = 4.5;
      privacy = 5.0;
      entertainment = 4.8;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _ratingRow('Luxury', luxury),
          _ratingRow('Location', location),
          _ratingRow('Privacy', privacy),
          _ratingRow(
            'Entertainment',
            entertainment,
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(
    String title,
    double rating,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: rating / 5,
              minHeight: 6,
              borderRadius:
                  BorderRadius.circular(10),
              backgroundColor:
                  Colors.white.withValues(
                alpha: 0.08,
              ),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF4DA6),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B1B1B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}