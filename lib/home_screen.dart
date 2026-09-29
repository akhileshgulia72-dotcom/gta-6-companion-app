import 'dart:async';

import 'package:gta_6_comapnion_app/explore_screen.dart';
import 'package:gta_6_comapnion_app/lucky_draw_screen.dart';
import 'package:gta_6_comapnion_app/news_service.dart' as news_api;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:gta_6_comapnion_app/news_model.dart';
import 'package:gta_6_comapnion_app/services/premium_screen.dart';
import 'package:gta_6_comapnion_app/services/premium_state.dart';


import 'package:slide_countdown/slide_countdown.dart';
import 'package:gta_6_comapnion_app/quiz_home_screen.dart';
import 'package:gta_6_comapnion_app/advanced_map_screen.dart';


import 'package:gta_6_comapnion_app/news_screen.dart';



class _EpicCountdownCard extends StatefulWidget {
  final DateTime release;

  const _EpicCountdownCard({required this.release});

  @override
  State<_EpicCountdownCard> createState() => _EpicCountdownCardState();
}

class _EpicCountdownCardState extends State<_EpicCountdownCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _motion;
  late final AnimationController _spark;

  Duration _remaining = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _spark = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _update();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _update(),
    );
  }

  void _update() {
    final value = widget.release.difference(DateTime.now());
    if (!mounted) return;

    setState(() {
      _remaining = value.isNegative ? Duration.zero : value;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    _motion.dispose();
    _spark.dispose();
    super.dispose();
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulse, _motion, _spark]),
        builder: (context, child) {
          final scale = 1 + (_pulse.value * .014);

          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF006E)
                        .withOpacity(.18 + _pulse.value * .08),
                    blurRadius: 35,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xFF8338EC)
                        .withOpacity(.12 + _pulse.value * .06),
                    blurRadius: 55,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF17091E),
                        Color(0xFF090F1D),
                        Color(0xFF120714),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFF006E).withOpacity(.42),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CountdownFirePainter(
                            motion: _motion.value,
                            spark: _spark.value,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -65,
                        top: -70,
                        child: _orb(const Color(0xFFFF006E), 150),
                      ),
                      Positioned(
                        right: -75,
                        bottom: -85,
                        child: _orb(const Color(0xFF8338EC), 180),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 15),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _spark,
                                  builder: (_, __) {
                                    return Transform.translate(
                                      offset: Offset(0, -2 * _spark.value),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFF006E),
                                              Color(0xFFFF7A00),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFF006E)
                                                  .withOpacity(.35),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.local_fire_department_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'GTA VI',
                                        style: GoogleFonts.bebasNeue(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      Text(
                                        'THE COUNTDOWN IS ON',
                                        style: GoogleFonts.orbitron(
                                          color: Colors.white54,
                                          fontSize: 7.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _liveBadge(),
                              ],
                            ),
                            const SizedBox(height: 17),
                            Text(
                              'NOVEMBER 19, 2026',
                              style: GoogleFonts.orbitron(
                                color: Colors.white38,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                Expanded(
                                  child: _timeBox(
                                    _two(days),
                                    'DAYS',
                                    const Color(0xFFFF006E),
                                  ),
                                ),
                                _colon(),
                                Expanded(
                                  child: _timeBox(
                                    _two(hours),
                                    'HOURS',
                                    const Color(0xFFFF4DA6),
                                  ),
                                ),
                                _colon(),
                                Expanded(
                                  child: _timeBox(
                                    _two(minutes),
                                    'MIN',
                                    const Color(0xFFB44CFF),
                                  ),
                                ),
                                _colon(),
                                Expanded(
                                  child: _timeBox(
                                    _two(seconds),
                                    'SEC',
                                    const Color(0xFF8338EC),
                                    flashing: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                height: 6,
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Colors.white.withOpacity(.055),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: _progress,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFFF006E),
                                              Color(0xFFFF4DA6),
                                              Color(0xFF8338EC),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'GRAND THEFT AUTO VI',
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white38,
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .7,
                                  ),
                                ),
                                Text(
                                  'PS5  •  XBOX SERIES X|S',
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white24,
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w700,
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
            ),
          );
        },
      ),
    );
  }

  double get _progress {
    const total = Duration(days: 365);
    final remaining = _remaining.inSeconds.clamp(0, total.inSeconds);
    return (1 - remaining / total.inSeconds).clamp(.03, 1.0);
  }

  Widget _orb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(.14),
            color.withOpacity(.035),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _liveBadge() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF006E).withOpacity(.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF006E)
                  .withOpacity(.25 + _pulse.value * .15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF006E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFFFF4DA6),
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        ':',
        style: GoogleFonts.bebasNeue(
          color: Colors.white24,
          fontSize: 27,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _timeBox(
    String value,
    String label,
    Color accent, {
    bool flashing = false,
  }) {
    return AnimatedBuilder(
      animation: _spark,
      builder: (_, __) {
        final borderOpacity = flashing
            ? .18 + _spark.value * .16
            : .20;

        return Container(
          height: 84,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.27),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: accent.withOpacity(borderOpacity),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(.07),
                blurRadius: 14,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.bebasNeue(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: .95,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: GoogleFonts.orbitron(
                  color: accent.withOpacity(.85),
                  fontSize: 6.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .9,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CountdownFirePainter extends CustomPainter {
  final double motion;
  final double spark;

  _CountdownFirePainter({
    required this.motion,
    required this.spark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 34; i++) {
      final seed = i * 43.7;
      final x = (seed + motion * size.width * 1.8) % size.width;
      final y = (seed * 1.61 + motion * size.height * .9) % size.height;
      final radius = .6 + (i % 3) * .45;

      paint.color = (i.isEven
              ? const Color(0xFFFF006E)
              : const Color(0xFF8338EC))
          .withOpacity(.10 + ((i % 5) * .025) + spark * .04);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final center = Offset(size.width * .83, size.height * .22);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFFFF006E).withOpacity(.11);

    for (int i = 0; i < 3; i++) {
      final rect = Rect.fromCircle(
        center: center,
        radius: 48.0 + i * 16,
      );

      canvas.drawArc(
        rect,
        motion * 6.283 + i * 1.7,
        1.25,
        false,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CountdownFirePainter oldDelegate) {
    return oldDelegate.motion != motion ||
        oldDelegate.spark != spark;
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _Homescrrenn();
}

class _Homescrrenn extends State<Homepage> {

InterstitialAd? interstitialAd;
bool isInterstitialReady = false;

int screenClickCount = 0;

  // ===============================================================
  // GTA 6 PRO AUTO POPUP
  // ===============================================================

  Timer? _premiumPopupTimer;
  bool _premiumPopupShown = false;

  void _startPremiumPopupTimer() {
    _premiumPopupTimer?.cancel();

    _premiumPopupTimer = Timer(const Duration(seconds: 25), () {
      if (!mounted || _premiumPopupShown || premiumState.isPremium) {
        return;
      }

      _showPremiumPopup();
    });
  }

  Future<void> _showPremiumPopup() async {
    if (!mounted || _premiumPopupShown || premiumState.isPremium) {
      return;
    }

    _premiumPopupShown = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: size.width,
              height: size.height * 0.82,
              child: const PremiumScreen(),
            ),
          ),
        );
      },
    );
  }

Widget _premiumMiniFeature(
  IconData icon,
  String label,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    ],
  );
}

  Widget _timeLabel(String text) {
  return Text(
    text,
    style: GoogleFonts.orbitron(
      color: Colors.white70,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}
  List<News> newsList = [];
  bool isLoadingNews = true;
  int currentIndex = 0;
 

  RewardedAd? rewardedAd;
  bool isRewardedReady = false;
  Future<void> loadNews() async {
  try {
    final service = news_api.NewsService();

    final news = await service.fetchNews();

    if (!mounted) return;

    setState(() {
      newsList = news;
      isLoadingNews = false;
    });
  } catch (e, stackTrace) {
    debugPrint('❌ NEWS ERROR: $e');
    debugPrint('❌ STACK: $stackTrace');

    if (!mounted) return;

    setState(() {
      isLoadingNews = false;
    });
  }
}

  void loadRewardedAd() {
    if (premiumState.isPremium) return;
    RewardedAd.load(
      adUnitId: 'ca-app-pub-7694497723149363/4829954140',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isRewardedReady = true;
        },
        onAdFailedToLoad: (error) {
          print(error);
        },
      ),
    );
  }
  void _onPremiumChanged() {
    if (!premiumState.isPremium) return;
    interstitialAd?.dispose();
    interstitialAd = null;
    isInterstitialReady = false;
    if (mounted) setState(() {});
  }

  void loadInterstitialAd() {
    if (premiumState.isPremium) return;
  InterstitialAd.load(
    adUnitId: "ca-app-pub-7694497723149363/3436835638",
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) {
        interstitialAd = ad;
        isInterstitialReady = true;
      },
      onAdFailedToLoad: (error) {
        isInterstitialReady = false;
      },
    ),
  );
}

  @override
  void initState() {
    super.initState();
    premiumState.addListener(_onPremiumChanged);
    if (!premiumState.isPremium) {
      loadInterstitialAd();
    }
    loadNews();
    _startPremiumPopupTimer();

    
    
  }

  @override
  void dispose() {
    _premiumPopupTimer?.cancel();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
    premiumState.removeListener(_onPremiumChanged);
    super.dispose();
  }

  void showRewardedAd() {
    // Explicit Watch & Earn remains available to PRO.
    if (rewardedAd != null) {
      rewardedAd!.show(onUserEarnedReward: (ad, reward) {});

      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();

          setState(() {
            currentIndex = 1;
          });

          
        },
      );
    } else {
      setState(() {
        currentIndex = 1;
      });
    }
  }
  void showInterstitialAd() {
    if (premiumState.isPremium) return;
    if (premiumState.isPremium) return;
  if (interstitialAd == null) return;

  interstitialAd!.show();

  interstitialAd!.fullScreenContentCallback =
      FullScreenContentCallback(
    onAdDismissedFullScreenContent: (ad) {
      ad.dispose();

      interstitialAd = null;
      isInterstitialReady = false;

      loadInterstitialAd();
    },
  );
}



  Widget _buildCommandCenter() {
    Widget action({
      required IconData icon,
      required String title,
      required String subtitle,
      required List<Color> colors,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            height: 116,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(.10)),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(.16),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 19),
                ),
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMMAND CENTER',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Your fastest route into GTA VI.',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink.withOpacity(.24)),
              ),
              child: Text(
                'LIVE HUB',
                style: GoogleFonts.orbitron(
                  color: Colors.pink,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            action(
              icon: Icons.newspaper_rounded,
              title: 'NEWS',
              subtitle: 'Latest drops',
              colors: const [Color(0xFF3A1645), Color(0xFF17111F)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewsScreen()),
              ),
            ),
            const SizedBox(width: 10),
            action(
              icon: Icons.map_rounded,
              title: 'MAP',
              subtitle: 'Explore Leonida',
              colors: const [Color(0xFF123B4A), Color(0xFF101B24)],
              onTap: () => setState(() => currentIndex = 1),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            action(
              icon: Icons.local_fire_department_rounded,
              title: 'EARN',
              subtitle: 'Coins & streaks',
              colors: const [Color(0xFF4B2811), Color(0xFF1D1510)],
              onTap: () => setState(() => currentIndex = 2),
            ),
            const SizedBox(width: 10),
            action(
              icon: Icons.explore_rounded,
              title: 'EXPLORE',
              subtitle: 'World & games',
              colors: const [Color(0xFF25174A), Color(0xFF13101D)],
              onTap: () => setState(() => currentIndex = 4),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime release = DateTime(2026, 11, 19);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(400, 80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 5, left: 15),
            child: Text(
              "Welcome...\n GTA 6 Companion...",
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            Icon(Icons.hail_sharp, size: 30),
            SizedBox(width: 10),
            Icon(Icons.monetization_on, size: 30),
            SizedBox(width: 10),
            Icon(Icons.notifications, size: 30),
          ],
        ),
      ),
      body: currentIndex == 3
        ? const LuckyDrawScreen()
        : currentIndex == 2
    ? const QuizHomeScreen()
          : currentIndex == 4
          ? const ExploreScreen()
          : currentIndex == 1
          ? const AdvancedMapScreen()
          : Stack(
              children: [
                // Home background image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/home_bg.png',
                    fit: BoxFit.cover,
                  ),
                ),

                // Dark overlay keeps all HomeScreen content readable
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),

                // Existing HomeScreen content
                SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  shadowColor: Colors.transparent,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: Colors.white.withOpacity(.14)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withOpacity(.20),
                                blurRadius: 28,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset("assets/images/gta6cover2.png", fit: BoxFit.cover),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(.15),
                                        Colors.black.withOpacity(.84),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 14,
                                  left: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(.62),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.white.withOpacity(.16)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF006E),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          'GTA VI • OFFICIAL COUNTDOWN',
                                          style: GoogleFonts.orbitron(
                                            color: Colors.white,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: .5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 18,
                                  right: 18,
                                  bottom: 16,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'GRAND THEFT AUTO VI',
                                              style: GoogleFonts.bebasNeue(
                                                color: Colors.white,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.4,
                                              ),
                                            ),
                                            Text(
                                              'NOVEMBER 19, 2026',
                                              style: GoogleFonts.orbitron(
                                                color: Colors.white70,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(.10),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white.withOpacity(.20)),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_downward_rounded,
                                          color: Colors.white,
                                          size: 18,
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
                      const SizedBox(height: 22),

                      _EpicCountdownCard(
                        release: release,
                      ),

// GTA 6 PRO PROMO
                          // =====================================================
                          Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 10),
                             child: GestureDetector(
                               onTap: () {
                                 Navigator.push(
                                   context,
                                   MaterialPageRoute(
                                     builder: (_) => const PremiumScreen(),
                                   ),
                                 );
                               },
                               child: Container(
                                 width: double.infinity,
                                 padding: const EdgeInsets.all(17),
                                 decoration: BoxDecoration(
                                   gradient: const LinearGradient(
                                     colors: [
                                       Color(0xFF5E0638),
                                       Color(0xFF42106D),
                                       Color(0xFF142B67),
                                     ],
                                     begin: Alignment.topLeft,
                                     end: Alignment.bottomRight,
                                   ),
                                   borderRadius: BorderRadius.circular(24),
                                   border: Border.all(color: const Color(0xFFFF4DA6).withOpacity(.38)),
                                   boxShadow: [
                                     BoxShadow(
                                       color: const Color(0xFFFF006E).withOpacity(.18),
                                       blurRadius: 24,
                                       spreadRadius: 1,
                                     ),
                                   ],
                                 ),
                                 child: Stack(
                                   children: [
                                     Positioned(
                                       right: -18,
                                       top: -22,
                                       child: Container(
                                         width: 105,
                                         height: 105,
                                         decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           color: Colors.white.withOpacity(.045),
                                         ),
                                       ),
                                     ),
                                     Row(
                                       children: [
                                         Container(
                                           width: 58,
                                           height: 58,
                                           decoration: BoxDecoration(
                                             gradient: const LinearGradient(
                                               colors: [Color(0xFFFFC83D), Color(0xFFFF8C00)],
                                             ),
                                             borderRadius: BorderRadius.circular(18),
                                             boxShadow: [
                                               BoxShadow(
                                                 color: Colors.amber.withOpacity(.22),
                                                 blurRadius: 14,
                                               ),
                                             ],
                                           ),
                                           child: const Icon(
                                             Icons.workspace_premium_rounded,
                                             color: Colors.black,
                                             size: 31,
                                           ),
                                         ),
                                         const SizedBox(width: 14),
                                         Expanded(
                                           child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Row(
                                                 children: [
                                                   Text(
                                                     'GTA 6 PRO',
                                                     style: GoogleFonts.bebasNeue(
                                                       color: Colors.white,
                                                       fontSize: 27,
                                                       fontWeight: FontWeight.bold,
                                                       letterSpacing: 1.5,
                                                     ),
                                                   ),
                                                   const SizedBox(width: 7),
                                                   Container(
                                                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                     decoration: BoxDecoration(
                                                       color: Colors.amber.withOpacity(.14),
                                                       borderRadius: BorderRadius.circular(7),
                                                       border: Border.all(color: Colors.amber.withOpacity(.35)),
                                                     ),
                                                     child: Text(
                                                       'PRO',
                                                       style: GoogleFonts.orbitron(
                                                         color: Colors.amber,
                                                         fontSize: 7,
                                                         fontWeight: FontWeight.w900,
                                                       ),
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                               const SizedBox(height: 2),
                                               Text(
                                                 '🎬 EXCLUSIVE CINEMATICS  •  🚫 ZERO ADS',
                                                 style: GoogleFonts.poppins(
                                                   color: Colors.white,
                                                   fontSize: 9.5,
                                                   fontWeight: FontWeight.w800,
                                                 ),
                                               ),
                                               const SizedBox(height: 3),
                                               Text(
                                                 'One-time purchase • Lifetime access',
                                                 style: GoogleFonts.poppins(
                                                   color: Colors.white60,
                                                   fontSize: 9,
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                         Container(
                                           padding: const EdgeInsets.all(9),
                                           decoration: BoxDecoration(
                                             color: Colors.white.withOpacity(.09),
                                             shape: BoxShape.circle,
                                             border: Border.all(color: Colors.white.withOpacity(.12)),
                                           ),
                                           child: const Icon(
                                             Icons.arrow_forward_rounded,
                                             color: Colors.white,
                                             size: 18,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                           ),
const SizedBox(height: 25),

                          // ADVANCED HOME COMMAND CENTER
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _buildCommandCenter(),
                          ),

                          const SizedBox(height: 25),

                          // LATEST NEWS — show only the 3 newest stories on Home.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'LATEST NEWS',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: .5,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const NewsScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.pink.withOpacity(.10),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.pink.withOpacity(.45),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'VIEW ALL NEWS',
                                          style: GoogleFonts.orbitron(
                                            color: Colors.pink,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 9,
                                            letterSpacing: .3,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.pink,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          isLoadingNews
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 35),
                                  child: CircularProgressIndicator(
                                    color: Colors.pink,
                                  ),
                                )
                              : newsList.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        'No news available right now.',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white54,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      // IMPORTANT: Home shows only the latest 3.
                                      itemCount: newsList.length > 3
                                          ? 3
                                          : newsList.length,
                                      itemBuilder: (context, index) {
                                        final news = newsList[index];

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const NewsScreen(),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 112,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF11121D)
                                                    .withOpacity(.94),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(.08),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(.20),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(18),
                                                      bottomLeft:
                                                          Radius.circular(18),
                                                    ),
                                                    child: Image.network(
                                                      news.image,
                                                      width: 125,
                                                      height: 112,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (_, __, ___) =>
                                                              Container(
                                                        width: 125,
                                                        height: 112,
                                                        color: Colors.black26,
                                                        child: const Icon(
                                                          Icons
                                                              .image_not_supported_outlined,
                                                          color: Colors.white54,
                                                          size: 32,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        vertical: 12,
                                                        horizontal: 2,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                           Container(
                                                             padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                             decoration: BoxDecoration(
                                                               color: Colors.pink.withOpacity(.10),
                                                               borderRadius: BorderRadius.circular(6),
                                                               border: Border.all(color: Colors.pink.withOpacity(.22)),
                                                             ),
                                                             child: Text(
                                                               news.category.toUpperCase(),
                                                               maxLines: 1,
                                                               overflow: TextOverflow.ellipsis,
                                                               style: GoogleFonts.orbitron(
                                                                 color: Colors.pink,
                                                                 fontSize: 6.5,
                                                                 fontWeight: FontWeight.w800,
                                                               ),
                                                             ),
                                                           ),
                                                           const SizedBox(height: 6),
                                                          Text(
                                                            news.title,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              height: 1.25,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Text(
                                                            news.description,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color: Colors
                                                                  .white54,
                                                              fontSize: 9.5,
                                                              height: 1.25,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                      right: 10,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      color: Colors.white38,
                                                      size: 21,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

      bottomNavigationBar: BottomNavigationBar(
  currentIndex: currentIndex,
  type: BottomNavigationBarType.fixed,
  backgroundColor: const Color(0xFF121212),
  selectedItemColor: Colors.pink,
  unselectedItemColor: Colors.grey,

  onTap: (index) {
  // Don't count clicking the screen already open
  if (index == currentIndex) return;

  // Don't count Home
  if (index == 0) {
    setState(() {
      currentIndex = index;
    });
    return;
  }

  // Count every major screen navigation
  screenClickCount++;

  // On every 3rd screen click, show ad
  if (screenClickCount == 3 && isInterstitialReady) {
    screenClickCount = 0;

    interstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();

        interstitialAd = null;
        isInterstitialReady = false;
        loadInterstitialAd();

        if (mounted) {
          setState(() {
            currentIndex = index;
          });
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();

        interstitialAd = null;
        isInterstitialReady = false;
        loadInterstitialAd();

        if (mounted) {
          setState(() {
            currentIndex = index;
          });
        }
      },
    );

    interstitialAd!.show();
  } else {
    setState(() {
      currentIndex = index;
    });
  }
},

  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: "Home",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.map_outlined),
      label: "Map",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.paid),
      label: "Earn Coins",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.card_giftcard),
      label: "Lucky Draw",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      label: "Explore",
    ),
  ],
),
    );
  }
}

// ================================================================
