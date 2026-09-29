// ExploreScreen
// Phase 1B ad pipeline:
// - Uses centralized AdManager for interstitials.
// - PRO users bypass interstitials.
// - Interstitial is requested centrally and navigations never block if unavailable.
// - Uses Color.withValues(alpha: ...) to avoid withOpacity deprecation warnings.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gta_6_comapnion_app/charaters.dart';

import 'premium_vehicles_screen.dart';
import 'premium_properties_screen.dart';
import 'premium_gallery_screen.dart';
import 'services/premium_screen.dart';
import 'street_rush_screen.dart';

import 'package:gta_6_comapnion_app/services/premium_state.dart';
import 'services/ad_manager.dart';
import 'leaderboard_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _exploreClickCount = 0;

  @override
  void initState() {
    super.initState();

    premiumState.addListener(_onPremiumChanged);

    if (!premiumState.isPremium) {
      AdManager.preloadInterstitial();
    }
  }

  void _onPremiumChanged() {
    if (!mounted) return;

    setState(() {});
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    // PRO users never see interstitial ads.
    if (premiumState.isPremium) {
      _navigateTo(context, screen);
      return;
    }

    _exploreClickCount++;

    // Show one interstitial after every 3rd Explore section click.
    if (_exploreClickCount >= 3) {
      _exploreClickCount = 0;

      AdManager.showInterstitial(
        onFinished: () {
          if (!mounted) return;
          _navigateTo(context, screen);
        },
      );

      return;
    }

    _navigateTo(context, screen);
  }

  @override
  void dispose() {
    premiumState.removeListener(_onPremiumChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080C),
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient premium lighting.
            Positioned(
              top: -120,
              right: -100,
              child: IgnorePointer(
                child: _GlowOrb(size: 310, color: const Color(0xFFFF3D9A)),
              ),
            ),

            Positioned(
              top: 380,
              left: -160,
              child: IgnorePointer(
                child: _GlowOrb(size: 330, color: const Color(0xFF6D4AFF)),
              ),
            ),

            Positioned(
              bottom: -150,
              right: -120,
              child: IgnorePointer(
                child: _GlowOrb(size: 300, color: const Color(0xFF00CFFF)),
              ),
            ),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 20),

                  const _PremiumExploreHero(),

                  const SizedBox(height: 30),

                  _buildSectionHeader(),

                  const SizedBox(height: 17),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _PremiumExploreCard(
                          title: 'CHARACTERS',
                          subtitle: 'Meet the cast',
                          index: '01',
                          icon: Icons.groups_rounded,
                          imagePath: 'assets/images/explore/characters_bg.png',
                          accent: const Color(0xFFFF3D9A),
                          onTap: () {
                            _openScreen(context, const CharaterScreen());
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PremiumExploreCard(
                          title: 'VEHICLES',
                          subtitle: 'Machines of Leonida',
                          index: '02',
                          icon: Icons.directions_car_filled_rounded,
                          imagePath: 'assets/images/explore/vehicles_bg.png',
                          accent: const Color(0xFF00D4FF),
                          onTap: () {
                            _openScreen(context, const PremiumVehiclesScreen());
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _PremiumExploreCard(
                          title: 'PROPERTIES',
                          subtitle: 'Luxury & safehouses',
                          index: '03',
                          icon: Icons.home_work_rounded,
                          imagePath: 'assets/images/explore/properties_bg.png',
                          accent: const Color(0xFF8B5CFF),
                          onTap: () {
                            _openScreen(
                              context,
                              const PremiumPropertiesScreen(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PremiumExploreCard(
                          title: 'GALLERY',
                          subtitle: 'Visual archive',
                          index: '04',
                          icon: Icons.photo_library_rounded,
                          imagePath: 'assets/images/explore/gallery_bg.png',
                          accent: const Color(0xFFFFC83D),
                          onTap: () {
                            _openScreen(context, const PremiumGalleryScreen());
                          },
                        ),
                      ),
                      
                    ],
                  ),

                  const SizedBox(height: 14),

                  const SizedBox(height: 14),

                  // WEEKLY LEADERBOARD — moved out of Home so it does not
                  // create a loading block on the main dashboard.
                  const ExploreLeaderboardCard(),

                  const SizedBox(height: 14),

                  // STREET RUSH — mini game.
                  _StreetRushExploreCard(
                    onTap: () {
                      _navigateTo(context, const StreetRushScreen());
                    },
                  ),

                  const SizedBox(height: 14),

                  // GTA 6 PRO — connected to the existing Premium screen.
                  _PremiumProExploreCard(
                    onTap: () {
                      _openScreen(context, const PremiumScreen());
                    },
                  ),

                  const SizedBox(height: 28),

                  

                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DISCOVER',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.20),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'EXPLORE',
              style: GoogleFonts.bebasNeue(
                color: Colors.white.withValues(alpha: 0.20),
                fontSize: 38,
                height: 0.95,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.055),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3D9A), Color(0xFF7047FF)],
                  ),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'VICE CITY',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE WORLD OF GTA VI',
                style: GoogleFonts.bebasNeue(
                  color: Colors.white,
                  fontSize: 27,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Explore every side of Vice City.',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        Text(
          '05 SECTIONS',
          style: GoogleFonts.poppins(
            color: Colors.white30,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 1,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFFF3D9A),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'YOUR GATEWAY TO THE GTA VI UNIVERSE',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'EXPLORE • DISCOVER • EXPERIENCE',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.20),
              fontSize: 7,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumExploreHero extends StatelessWidget {
  const _PremiumExploreHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3D9A).withValues(alpha: 0.13),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/explore/explore_hero.png',
              fit: BoxFit.cover,
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.93),
                  ],
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black.withValues(alpha: 0.48), Colors.transparent],
                ),
              ),
            ),

            Positioned(
              top: 18,
              left: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.48),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3D9A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'EXPLORATION MODE',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VICE CITY',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF3D9A),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'AWAITS.',
                    style: GoogleFonts.bebasNeue(
                      color: Colors.white,
                      fontSize: 43,
                      height: 0.95,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Characters • Vehicles • Properties • Gallery',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 18,
              bottom: 18,
              child: Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3D9A).withValues(alpha: 0.28),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumExploreCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String index;
  final IconData icon;
  final String imagePath;
  final Color accent;
  final VoidCallback onTap;

  const _PremiumExploreCard({
    required this.title,
    required this.subtitle,
    required this.index,
    required this.icon,
    required this.imagePath,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: 188,
          decoration: BoxDecoration(
            color: const Color(0xFF111218),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(imagePath, fit: BoxFit.cover),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.10),
                        Colors.black.withValues(alpha: 0.38),
                        Colors.black.withValues(alpha: 0.93),
                      ],
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.42),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 13,
                  left: 13,
                  right: 13,
                  child: Row(
                    children: [
                      Text(
                        index,
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.42),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: accent.withValues(alpha: 0.45)),
                        ),
                        child: Icon(icon, color: accent, size: 15),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 2,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.65),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.bebasNeue(
                          color: Colors.white,
                          fontSize: 23,
                          height: 0.95,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white70,
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.11),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _StreetRushExploreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StreetRushExploreCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 178,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF171020),
                Color(0xFF0C111A),
                Color(0xFF1B1024),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFFF3D9A).withValues(alpha: 0.34),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3D9A).withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0xFF00D4FF).withValues(alpha: 0.07),
                blurRadius: 35,
                offset: const Offset(20, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -45,
                  top: -65,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF3D9A).withValues(alpha: 0.07),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF3D9A).withValues(alpha: 0.14),
                          blurRadius: 70,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 16,
                  child: Icon(
                    Icons.sports_motorsports_rounded,
                    size: 86,
                    color: Colors.white.withValues(alpha: 0.055),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 17,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3D9A).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFF3D9A).withValues(alpha: 0.30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sports_motorsports_rounded,
                          color: Color(0xFFFF5CAC),
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'NEW GAME',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(17, 62, 17, 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'STREET RUSH',
                              style: GoogleFonts.bebasNeue(
                                color: Colors.white,
                                fontSize: 31,
                                height: 0.95,
                                letterSpacing: 1.6,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Drive • Escape • Collect • Survive',
                              style: GoogleFonts.poppins(
                                color: Colors.white60,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 11),
                            Row(
                              children: [
                                _RushMiniTag(
                                  icon: Icons.monetization_on_rounded,
                                  label: 'EARN COINS',
                                ),
                                const SizedBox(width: 7),
                                _RushMiniTag(
                                  icon: Icons.local_police_rounded,
                                  label: 'ESCAPE COPS',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFF3D9A),
                              Color(0xFF7047FF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF3D9A).withValues(alpha: 0.30),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 29,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFFFF3D9A),
                          Color(0xFF7047FF),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RushMiniTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RushMiniTag({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: const Color(0xFFFFC83D),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 6.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumProExploreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PremiumProExploreCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 138,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF171020),
                Color(0xFF0F111A),
                Color(0xFF171122),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFFF3D9A).withValues(alpha: 0.32),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3D9A).withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0xFF7047FF).withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(20, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -45,
                  top: -70,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF3D9A).withValues(alpha: 0.08),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF3D9A).withValues(alpha: 0.15),
                          blurRadius: 65,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  top: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC83D).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFFC83D).withValues(alpha: 0.30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFFFC83D),
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'PRO',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFD76A),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(17, 17, 17, 15),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFF3D9A),
                              Color(0xFF7047FF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF3D9A).withValues(alpha: 0.28),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'GTA 6 PRO',
                                style: GoogleFonts.bebasNeue(
                                  color: Colors.white,
                                  fontSize: 27,
                                  height: 0.95,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Premium access • Cinematics • Zero Ads',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white60,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF3D9A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'UNLOCK THE FULL EXPERIENCE',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white54,
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFFFF3D9A),
                          Color(0xFF7047FF),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.035),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 120,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EXPLORE LEADERBOARD
// ================================================================

// HOME LEADERBOARD PREVIEW
// ================================================================

class ExploreLeaderboardCard extends StatefulWidget {
  const ExploreLeaderboardCard({super.key});

  @override
  State<ExploreLeaderboardCard> createState() => _ExploreLeaderboardCardState();
}

class _ExploreLeaderboardCardState extends State<ExploreLeaderboardCard> {
  static const String _leaderboardUrl =
      'https://script.google.com/macros/s/AKfycbwhl1aO-hidPhIMgSAAB2EdhY_XYUVWPv6t4Tj72upIDsnMZDMljwMqfa4JdjevGNns/exec?action=leaderboard';

  late Future<LeaderboardConfig> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _fetchLeaderboard();
  }

  Future<LeaderboardConfig> _fetchLeaderboard() async {
    final response = await http
        .get(Uri.parse(_leaderboardUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Leaderboard unavailable');
    }

    return LeaderboardConfig.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LeaderboardConfig>(
      future: _leaderboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShell(
            child: const SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.pink,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildShell(
            child: _buildFallback(),
          );
        }

        return _buildShell(
          child: _buildLeaderboard(snapshot.data!),
        );
      },
    );
  }

  Widget _buildShell({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151020), Color(0xFF0B0C14)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.pink.withOpacity(.30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(.10),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLeaderboard(LeaderboardConfig config) {
    final players = config.weekly.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(17, 16, 17, 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF27102F),
                Color(0xFF111323),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFC83D),
                      Color(0xFFFF8C00),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    '🏆',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY LEADERBOARD',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'TOP 5 • COINS SPENT',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LeaderboardScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.pink.withOpacity(.30),
                    ),
                  ),
                  child: Text(
                    'VIEW ALL',
                    style: GoogleFonts.orbitron(
                      color: Colors.pink,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (players.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No leaderboard data yet.',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          )
        else
          ...players.map(
            (player) => _playerRow(player),
          ),

        Container(
          margin: const EdgeInsets.fromLTRB(14, 4, 14, 14),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(.06),
            ),
          ),
          child: Row(
            children: [
              const Text(
                '🎁',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.topperPrize,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Weekly topper gets ${config.luckyDrawMultiplier}× Lucky Draw boost',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _playerRow(LeaderboardEntry player) {
    final rank = player.rank;
    final medal = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : '🥉';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.055),
            Colors.white.withOpacity(.018),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(.045)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              medal,
              style: const TextStyle(fontSize: 19),
            ),
          ),
          _homeRankAvatar(player.rank),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Text(
            '🪙',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 4),
          Text(
            _formatNumber(player.coinsSpent),
            style: GoogleFonts.orbitron(
              color: const Color(0xFFFFC83D),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Padding(
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEKLY LEADERBOARD',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tap to view the latest rankings.',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaderboardScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeRankAvatar(int rank) {
    final safeRank = rank.clamp(1, 5);
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(.22),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/avatars/avatar_$safeRank.jpg',
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF8A2BE2),
                    Color(0xFFFF4DA6),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$safeRank',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String _formatNumber(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }
}

