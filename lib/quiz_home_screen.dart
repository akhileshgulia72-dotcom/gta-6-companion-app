import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gta_6_comapnion_app/quiz_screen.dart';
import 'rewarded_ad_service.dart';

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key});

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  int coins = 0;
  int watchCount = 0;

  @override
  void initState() {
    super.initState();
    loadData();
    RewardedAdService.loadRewardedAd();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    String today =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

    String savedDate = prefs.getString("watchDate") ?? "";

    if (savedDate != today) {
      await prefs.setString("watchDate", today);
      await prefs.setInt("watchCount", 0);
    }

    setState(() {
      coins = prefs.getInt("coins") ?? 0;
      watchCount = prefs.getInt("watchCount") ?? 0;
    });
  }

  Future<void> watchReward() async {
    if (watchCount >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Daily watch limit reached."),
        ),
      );
      return;
    }

    RewardedAdService.showRewardedAd(
      onReward: () async {
        final prefs = await SharedPreferences.getInstance();

        coins += 100;
        watchCount++;

        await prefs.setInt("coins", coins);
        await prefs.setInt("watchCount", watchCount);

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 You earned 100 Coins!"),
          ),
        );
      },
    );
  }

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
        border: Border.all(color: color, width: 2),
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
                  borderRadius: BorderRadius.circular(15),
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
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffFF4DA6),
                    Color(0xff8A2BE2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "Your Coins",
                    style: GoogleFonts.orbitron(
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
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

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
                    builder: (_) => QuizScreen(
                      onBackHome: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ).then((_) {
                  loadData();
                });
              },
            ),

            buildCard(
              icon: Icons.ondemand_video,
              title: "Watch & Earn Coins",
              subtitle:
                  "Watch a Rewarded Ad\n\nReward: 100 Coins\n\nRemaining Today: ${10 - watchCount}/10",
              color: Colors.green,
              buttonText: "WATCH AD",
              onPressed: watchReward,
            ),
          ],
        ),
      ),
    );
  }
}