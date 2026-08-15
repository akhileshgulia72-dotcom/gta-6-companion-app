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

  Future<void> joinTelegram() async {
  final Uri telegramUrl = Uri.parse(
    'https://t.me/gta6companion',
  );

  if (!await launchUrl(
    telegramUrl,
    mode: LaunchMode.externalApplication,
  )) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Could not open Telegram."),
      ),
    );
  }
}

Future<void> claimTelegramReward() async {
  final prefs = await SharedPreferences.getInstance();

  final bool alreadyClaimed =
      prefs.getBool("telegramRewardClaimed") ?? false;

  if (alreadyClaimed) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "You have already claimed your Telegram reward.",
        ),
      ),
    );

    return;
  }

  // Add 1,000 coins to the existing balance.
  coins += 1000;

  await prefs.setInt("coins", coins);

  // Prevent repeated claiming.
  await prefs.setBool(
    "telegramRewardClaimed",
    true,
  );

  if (!mounted) return;

  setState(() {});

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "🎉 +1,000 Coins added!",
      ),
    ),
  );
}

  // 🔥 STREAK DATA
  int streak = 0;
  int highestStreak = 0;
  String badge = "No Badge Yet";

  @override
  void initState() {
    super.initState();

    loadData();

    RewardedAdService.loadRewardedAd();
  }

  // ============================================================
  // LOAD ALL QUIZ CENTER DATA
  // ============================================================

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final String today =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

    final String savedDate =
        prefs.getString("watchDate") ?? "";

    // Reset daily rewarded-ad watch count.
    if (savedDate != today) {
      await prefs.setString("watchDate", today);
      await prefs.setInt("watchCount", 0);
    }

    // Load coins.
    final int savedCoins =
        prefs.getInt("coins") ?? 0;

    // Load watch count.
    final int savedWatchCount =
        prefs.getInt("watchCount") ?? 0;

    // Load current streak.
    final int savedStreak =
        prefs.getInt("quizStreak") ?? 0;

    // Load highest streak ever achieved.
    final int savedHighestStreak =
        prefs.getInt("highestQuizStreak") ?? 0;

    // Determine permanent badge.
    String savedBadge = "No Badge Yet";

    if (savedHighestStreak >= 7) {
      savedBadge = "🏆 7-Day Legend";
    } else if (savedHighestStreak >= 6) {
      savedBadge = "👑 6-Day Master";
    } else if (savedHighestStreak >= 5) {
      savedBadge = "💎 5-Day Elite";
    } else if (savedHighestStreak >= 4) {
      savedBadge = "⚡ 4-Day Hunter";
    } else if (savedHighestStreak >= 3) {
      savedBadge = "🔥 3-Day Grinder";
    } else if (savedHighestStreak >= 2) {
      savedBadge = "⚔️ 2-Day Warrior";
    } else if (savedHighestStreak >= 1) {
      savedBadge = "🔥 Streak Starter";
    }

    if (!mounted) return;

    setState(() {
      coins = savedCoins;
      watchCount = savedWatchCount;
      streak = savedStreak;
      highestStreak = savedHighestStreak;
      badge = savedBadge;
    });
  }

  // ============================================================
  // WATCH & EARN
  // ============================================================

  Future<void> watchReward() async {
    if (watchCount >= 10) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Daily watch limit reached."),
        ),
      );

      return;
    }

    RewardedAdService.showRewardedAd(
      onReward: () async {
        final prefs =
            await SharedPreferences.getInstance();

        coins += 100;
        watchCount++;

        await prefs.setInt(
          "coins",
          coins,
        );

        await prefs.setInt(
          "watchCount",
          watchCount,
        );

        if (!mounted) return;

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "🎉 You earned 100 Coins!",
            ),
          ),
        );
        
      },
    );
    
  }
  

  // ============================================================
  // COMMON QUIZ CARD
  // ============================================================

  Widget buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 70,
          ),

          const SizedBox(height: 20),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STREAK CARD
  // ============================================================

  Widget buildStreakCard() {
    String streakMessage;

    if (streak == 0) {
      streakMessage =
          "Complete today's quiz to start your streak!";
    } else if (streak < 7) {
      streakMessage =
          "${7 - streak} more days to reach 🏆 7-Day Legend";
    } else {
      streakMessage =
          "🔥 Legendary streak! Keep going!";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orangeAccent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                "🔥",
                style: TextStyle(
                  fontSize: 28,
                ),
              ),

              const SizedBox(width: 8),

              Text(
                "DAILY STREAK",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "$streak DAYS",
            style: GoogleFonts.orbitron(
              color: Colors.orangeAccent,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            badge,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            streakMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 15),

          // 7-DAY PROGRESS
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: List.generate(
              7,
              (index) {
                final int day = index + 1;

                final bool completed =
                    streak >= day;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed
                        ? Colors.orangeAccent
                        : Colors.white10,
                    border: Border.all(
                      color: completed
                          ? Colors.orangeAccent
                          : Colors.white24,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "$day",
                      style: TextStyle(
                        color: completed
                            ? Colors.black
                            : Colors.white54,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 15),

          Text(
            streak >= 7
                ? "🏆 7-Day Legend unlocked!"
                : "Keep playing every day to earn bigger rewards!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: streak >= 7
                  ? Colors.amber
                  : Colors.white54,
              fontSize: 13,
              fontWeight:
                  streak >= 7
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff121212),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          "Quiz Center",
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            // ==================================================
            // COINS CARD
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xffFF4DA6),
                    Color(0xff8A2BE2),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  Text(
                    "Your Coins",
                    style:
                        GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        "$coins",
                        style:
                            GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // DAILY STREAK
            // ==================================================

            buildStreakCard(),

            const SizedBox(height: 30),

            // ==================================================
            // DAILY QUIZ
            // ==================================================

            buildCard(
              icon: Icons.quiz,
              title: "Play Daily Quiz",
              subtitle:
                  "10 Questions\nEarn Coins\nDaily Reset",
              color: Colors.pinkAccent,
              buttonText: "PLAY NOW",

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuizScreen(
                      onBackHome: () {
                        Navigator.pop(
                          context,
                        );
                      },
                    ),
                  ),
                ).then((_) {
                  // Refresh coins + streak
                  // after returning.
                  loadData();
                });
              },
            ),

            // ==================================================
            // WATCH & EARN
            // ==================================================

            buildCard(
              icon:
                  Icons.ondemand_video,
              title:
                  "Watch & Earn Coins",
              subtitle:
                  "Watch a Rewarded Ad\n\n"
                  "Reward: 100 Coins\n\n"
                  "Remaining Today: "
                  "${10 - watchCount}/10",
              color: Colors.green,
              buttonText: "WATCH VIDEO",
              onPressed: watchReward,
            ),
            const SizedBox(height: 5),

// ==================================================
// JOIN TELEGRAM COMMUNITY
// ==================================================

buildCard(
  icon: Icons.telegram,
  title: "Join Our Community",
  subtitle:
      "Stay updated every day\n"
      "GTA 6 News • Updates • Events\n\n"
      "Reward: 1,000 Coins",
  color: Colors.lightBlueAccent,
  buttonText: "JOIN TELEGRAM",
  onPressed: joinTelegram,
),

const SizedBox(height: 5),

buildCard(
  icon: Icons.card_giftcard,
  title: "Claim Telegram Reward",
  subtitle:
      "Joined our community?\n"
      "Claim your 1,000 Coins reward!",
  color: Colors.amber,
  buttonText: "VERIFY & CLAIM",
  onPressed: claimTelegramReward,
),
          ],
        ),
      ),
    );
  }
}