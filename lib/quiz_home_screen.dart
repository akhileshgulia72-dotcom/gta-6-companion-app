import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gta_6_comapnion_app/quiz_screen.dart';
import 'rewarded_ad_service.dart';
import 'package:url_launcher/url_launcher.dart';

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key});

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  int coins = 0;
  int watchCount = 0;
  int streak = 0;
  int highestStreak = 0;
  String badge = 'No Badge Yet';
  bool isLoading = true;
  bool isClaiming = false;

  static const int dailyWatchLimit = 10;
  static const int rewardPerAd = 100;
  static const int telegramReward = 1000;

  @override
  void initState() {
    super.initState();
    loadData();

    // Preload exactly ONE rewarded ad when Quiz Center opens.
    // It is shown only after the user taps WATCH & EARN.
    RewardedAdService.preloadRewardedAd();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final String today =
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';

    final String savedDate = prefs.getString('watchDate') ?? '';

    if (savedDate != today) {
      await prefs.setString('watchDate', today);
      await prefs.setInt('watchCount', 0);
    }

    final int savedCoins = prefs.getInt('coins') ?? 0;
    final int savedWatchCount = prefs.getInt('watchCount') ?? 0;
    final int savedStreak = prefs.getInt('quizStreak') ?? 0;
    final int savedHighestStreak =
        prefs.getInt('highestQuizStreak') ?? 0;

    String savedBadge = 'No Badge Yet';

    if (savedHighestStreak >= 7) {
      savedBadge = '🏆 7-Day Legend';
    } else if (savedHighestStreak >= 6) {
      savedBadge = '👑 6-Day Master';
    } else if (savedHighestStreak >= 5) {
      savedBadge = '💎 5-Day Elite';
    } else if (savedHighestStreak >= 4) {
      savedBadge = '⚡ 4-Day Hunter';
    } else if (savedHighestStreak >= 3) {
      savedBadge = '🔥 3-Day Grinder';
    } else if (savedHighestStreak >= 2) {
      savedBadge = '⚔️ 2-Day Warrior';
    } else if (savedHighestStreak >= 1) {
      savedBadge = '🔥 Streak Starter';
    }

    if (!mounted) return;

    setState(() {
      coins = savedCoins;
      watchCount = savedWatchCount;
      streak = savedStreak;
      highestStreak = savedHighestStreak;
      badge = savedBadge;
      isLoading = false;
    });
  }

  Future<void> joinTelegram() async {
    if (isClaiming) return;

    final prefs = await SharedPreferences.getInstance();
    final bool alreadyClaimed =
        prefs.getBool('telegramRewardClaimed') ?? false;

    // This reward is a one-time first-click reward. Once the timer starts,
    // this flag prevents the user from starting another reward timer later.
    if (alreadyClaimed) {
      if (mounted) {
        _showMessage('You already received the Telegram community reward.');
      }
      return;
    }

    // Reserve the one-time reward BEFORE opening Telegram so the user cannot
    // repeatedly come back and start multiple 22-second reward timers.
    await prefs.setBool('telegramRewardClaimed', true);

    if (!mounted) return;
    setState(() => isClaiming = true);

    final Uri telegramUrl = Uri.parse('https://t.me/gta6companion');

    final bool opened = await launchUrl(
      telegramUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      // The reward is still one-time, but the user is told that Telegram
      // could not be opened. No second reward attempt is allowed.
      if (mounted) {
        setState(() => isClaiming = false);
        _showMessage('Could not open Telegram. Your one-time reward is reserved.');
      }
      return;
    }

    if (mounted) {
      _showMessage('Telegram opened. Stay for 2 seconds to receive +1,000 coins.');
    }

    // Wait 22 seconds while the first reward timer is active.
    await Future.delayed(const Duration(seconds: 2));

    final int newCoins = coins + telegramReward;
    await prefs.setInt('coins', newCoins);

    if (!mounted) return;

    setState(() {
      coins = newCoins;
      isClaiming = false;
    });

    _showMessage('🎉 +1,000 Coins added for joining the community!');
  }

  Future<void> watchReward() async {
    if (watchCount >= dailyWatchLimit) {
      _showMessage('Daily watch limit reached. Come back tomorrow.');
      return;
    }

    if (!mounted) return;

    // The service prevents duplicate taps and waits for the single
    // preloaded/requested ad to become ready.
    await RewardedAdService.showRewardedAd(
      onReward: () async {
        final prefs = await SharedPreferences.getInstance();

        // Protect against a reward callback arriving after the daily limit.
        if (watchCount >= dailyWatchLimit) return;

        final int newCoins = coins + rewardPerAd;
        final int newWatchCount = watchCount + 1;

        await prefs.setInt('coins', newCoins);
        await prefs.setInt('watchCount', newWatchCount);

        if (!mounted) return;

        setState(() {
          coins = newCoins;
          watchCount = newWatchCount;
        });

        _showMessage('🎉 +100 Coins added!');
      },
      onAdPreparing: () {
        _showMessage('Preparing your reward video…');
      },
      onAdNotReady: () {
        _showMessage('Rewarded video is not ready yet. Please try again in a moment.');
      },
    );
  }

  void openDailyQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          onBackHome: () {
            Navigator.pop(context);
          },
        ),
      ),
    ).then((_) => loadData());
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
    EdgeInsets margin = EdgeInsets.zero,
    BorderRadius radius = const BorderRadius.all(Radius.circular(24)),
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF17171D),
        borderRadius: radius,
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B1534),
            Color(0xFF17171D),
            Color(0xFF101014),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF4DA6),
                  Color(0xFF8A2BE2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4DA6).withOpacity(0.22),
                  blurRadius: 22,
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUIZ CENTER',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Test your GTA VI knowledge.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.amber.withOpacity(0.22),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.amber,
                  size: 19,
                ),
                const SizedBox(width: 6),
                Text(
                  '$coins',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final int progress = streak.clamp(0, 7).toInt();
    final String message = streak == 0
        ? "Complete today's quiz to start your streak."
        : streak >= 7
            ? 'Legendary streak. Keep it alive.'
            : '${7 - streak} more day${7 - streak == 1 ? '' : 's'} to reach 7-Day Legend.';

    return _glassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text('🔥', style: TextStyle(fontSize: 23)),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY STREAK',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$streak',
                style: GoogleFonts.orbitron(
                  color: Colors.orangeAccent,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 7,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.orangeAccent,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: List.generate(
              7,
              (index) {
                final bool completed = streak >= index + 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == 6 ? 0 : 5,
                    ),
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: completed
                            ? Colors.orangeAccent
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: completed
                                ? Colors.black
                                : Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String eyebrow,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    required List<Color> gradient,
    String? badgeText,
    bool loading = false,
    String? rewardText,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(.09)),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(.16),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
          child: Column(
            children: [
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: .92, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.10),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(.08),
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            color: Colors.white54,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (rewardText != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            rewardText,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(.08),
                        ),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.orbitron(
                          color: Colors.white70,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: loading ? null : onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.white24,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  buttonText,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsStrip() {
    return Row(
      children: [
        Expanded(
          child: _statBox(
            icon: Icons.local_fire_department_rounded,
            value: '$streak',
            label: 'STREAK',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statBox(
            icon: Icons.emoji_events_rounded,
            value: '$highestStreak',
            label: 'BEST',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statBox(
            icon: Icons.play_circle_fill_rounded,
            value: '$watchCount/$dailyWatchLimit',
            label: 'ADS TODAY',
          ),
        ),
      ],
    );
  }

  Widget _statBox({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return _glassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),
      radius: const BorderRadius.all(Radius.circular(18)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white54, size: 19),
          const SizedBox(height: 7),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinVault() {
    final int earnedToday = watchCount * rewardPerAd;
    final double progress = watchCount / dailyWatchLimit;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF35122E), Color(0xFF16131D), Color(0xFF101116)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.pink.withOpacity(.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(.10),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC83D), Color(0xFFFF7A00)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(.18),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.black,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COIN VAULT',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Build your balance every day.',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$coins',
                style: GoogleFonts.orbitron(
                  color: Colors.amber,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'TODAY\'S REWARD RUN',
                  style: GoogleFonts.orbitron(
                    color: Colors.white54,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                '+$earnedToday COINS',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Text(
                '$watchCount/$dailyWatchLimit reward videos',
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
              const Spacer(),
              Text(
                '${dailyWatchLimit - watchCount} remaining',
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionGrid() {
    Widget mission({
      required IconData icon,
      required String title,
      required String subtitle,
      required Color accent,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: onTap,
          child: Container(
            height: 104,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFF15161C),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: Colors.white.withOpacity(.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: accent, size: 22),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 8.5),
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
        _sectionLabel('Quick missions'),
        Row(
          children: [
            mission(
              icon: Icons.quiz_rounded,
              title: 'DAILY QUIZ',
              subtitle: 'Build streak',
              accent: Colors.pinkAccent,
              onTap: openDailyQuiz,
            ),
            const SizedBox(width: 9),
            mission(
              icon: Icons.play_circle_fill_rounded,
              title: 'WATCH & EARN',
              subtitle: '+100 coins',
              accent: Colors.greenAccent,
              onTap: watchReward,
            ),
            const SizedBox(width: 9),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0C10),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          'QUIZ',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildCoinVault(),
                  const SizedBox(height: 14),
                  _buildMissionGrid(),
                  const SizedBox(height: 20),
                  _buildStatsStrip(),
                  const SizedBox(height: 24),
                  _sectionLabel('Your progress'),
                  _buildStreakCard(),
                  const SizedBox(height: 12),
                  _sectionLabel('Earn coins'),
                  _buildActionCard(
                    icon: Icons.quiz_rounded,
                    eyebrow: 'Daily',
                    title: 'Play Quiz',
                    subtitle: '10 questions • Daily reset',
                    rewardText: '+ coins & streak',
                    buttonText: 'PLAY',
                    gradient: const [
                      Color(0xFF7C1F56),
                      Color(0xFF281535),
                    ],
                    badgeText: 'DAILY',
                    onPressed: openDailyQuiz,
                  ),
                  _buildActionCard(
                    icon: Icons.play_circle_fill_rounded,
                    eyebrow: 'Reward',
                    title: 'Watch & Earn',
                    subtitle: 'Complete a video to earn coins',
                    rewardText: '+100 coins / video',
                    buttonText: 'WATCH',
                    gradient: const [
                      Color(0xFF15583F),
                      Color(0xFF132A25),
                    ],
                    badgeText: '$watchCount/$dailyWatchLimit',
                    onPressed: watchReward,
                  ),
                  _sectionLabel('Community'),
                  _buildActionCard(
                    icon: Icons.telegram_rounded,
                    eyebrow: 'One-time reward',
                    title: 'Join Our Community',
                    subtitle: 'GTA 6 news, events & announcements',
                    rewardText: '+1,000 coins • 22 sec',
                    buttonText: 'JOIN',
                    loading: isClaiming,
                    gradient: const [
                      Color(0xFF174D69),
                      Color(0xFF12252F),
                    ],
                    badgeText: '+1,000',
                    onPressed: joinTelegram,
                  ),
                ],
              ),
            ),
    );
  }
}
