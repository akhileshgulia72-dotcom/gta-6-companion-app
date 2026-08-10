import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gta_6_comapnion_app/main.dart';
import 'dart:math';

import 'package:gta_6_comapnion_app/questions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizScreen extends StatefulWidget {
  final VoidCallback onBackHome;
  const QuizScreen({super.key, required this.onBackHome});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {


  
  InterstitialAd? interstitialAd;
  bool isInterstitialReady = false;
  bool quizCompleted = false;
  RewardedAd? rewardedAd;
  bool isRewardedReady = false;
  int coins = 0;
  late List<Question> todayQuestions;
  late Question currentQuestion;
  int currentQuestionIndex = 0;
  int? selectedAnswer;
  bool answeredCorrect = false;
  bool rewardClaimed = false;

  bool answerSelected = false;

  int score = 0;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-7694497723149363/3436835638", // 
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isInterstitialReady = true;
        },
        onAdFailedToLoad: (error) {
          isInterstitialReady = false;
          debugPrint(error.toString());
        },
      ),
    );
  }

  Future<void> loadQuestionIndex() async {
    final prefs = await SharedPreferences.getInstance();

    String today =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

    String savedDate = prefs.getString("quizDate") ?? "";

    // New day
    if (savedDate != today) {
      await prefs.setString("quizDate", today);
      await prefs.setBool("quizCompleted", false);
      await prefs.setInt("questionIndex", 0);
    }

    bool completed = prefs.getBool("quizCompleted") ?? false;

    if (completed) {
      setState(() {
        quizCompleted = true;
      });
      return;
    }

    currentQuestionIndex = prefs.getInt("questionIndex") ?? 0;

    if (currentQuestionIndex >= todayQuestions.length) {
      currentQuestionIndex = 0;
    }

    setState(() {
      currentQuestion = todayQuestions[currentQuestionIndex];
    });
  }

  Future<void> saveQuizProgress() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt("coins", coins);
  await prefs.setInt("questionIndex", currentQuestionIndex);

  await prefs.setBool("answerSelected", answerSelected);
  await prefs.setInt("selectedAnswer", selectedAnswer ?? -1);
  await prefs.setBool("answeredCorrect", answeredCorrect);

  String today =
      "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
  await prefs.setString("quizDate", today);
}
  Future<void> loadCoins() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    coins = prefs.getInt("coins") ?? 0;
  });
}
Future<void> loadQuizProgress() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    coins = prefs.getInt("coins") ?? 0;

    currentQuestionIndex = prefs.getInt("questionIndex") ?? 0;

    answerSelected = prefs.getBool("answerSelected") ?? false;

    int savedAnswer = prefs.getInt("selectedAnswer") ?? -1;
    selectedAnswer = savedAnswer == -1 ? null : savedAnswer;

    answeredCorrect = prefs.getBool("answeredCorrect") ?? false;

    currentQuestion = todayQuestions[currentQuestionIndex];
  });
}

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: "ca-app-pub-7694497723149363/4829954140",
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isRewardedReady = true;
        },
        onAdFailedToLoad: (error) {
          isRewardedReady = false;
          debugPrint(error.toString());
        },
      ),
    );
  }

  void showRewardedAd() {
    if (!isRewardedReady || rewardedAd == null) {
      return;
    }

    rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        setState(() {
          rewardClaimed = true;

          if (answeredCorrect) {
            coins += 100;
            saveQuizProgress();
          } else {
            coins += 100;
            saveQuizProgress();
          }
        });
      },
    );

    rewardedAd = null;
    isRewardedReady = false;

    loadRewardedAd();
  }

  void showInterstitialAd() {
    if (interstitialAd == null) return;

    interstitialAd!.show();

    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        interstitialAd = null;
        isInterstitialReady = false;

        loadInterstitialAd();
      },
    );
  }

  Color getOptionColor(int index) {
    if (!answerSelected) {
      return const Color(0xCC1A1A1A);
    }

    if (index == currentQuestion.answerIndex) {
      return Colors.green;
    }

    if (index == selectedAnswer) {
      return Colors.red;
    }

    return const Color(0xCC1A1A1A);
  }

  void nextQuestion() async {
    if (currentQuestionIndex < todayQuestions.length - 1) {
      currentQuestionIndex++;

      if ((currentQuestionIndex + 1) % 3 == 0 && isInterstitialReady) {
        showInterstitialAd();
      }

      await saveQuizProgress();

      setState(() {
        currentQuestion = todayQuestions[currentQuestionIndex];
        selectedAnswer = null;
        answerSelected = false;
        answeredCorrect = false;
        rewardClaimed = false;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool("quizCompleted", true);
      await prefs.setInt("questionIndex", todayQuestions.length);
      await prefs.setString(
        "quizDate",
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
      );

      setState(() {
        quizCompleted = true;
      });
    }
  }

  List<Question> getTodayQuestions() {
    final now = DateTime.now();

    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    final questions = List<Question>.from(allquestions);
    questions.shuffle(random);
    return questions.take(10).toList();
  }

  @override
  void initState() {
    super.initState();

    loadRewardedAd();
    loadInterstitialAd();

    todayQuestions = getTodayQuestions();

    // Temporary question so the screen doesn't crash
    currentQuestion = todayQuestions[0];
   loadQuestionIndex().then((_) {
  loadQuizProgress();
});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            widget.onBackHome();
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Column(
          children: [
            Text(
              "Quiz",
              style: GoogleFonts.aboreto(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "GTA 6",
              style: GoogleFonts.orbitron(
                color: Colors.pinkAccent,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff1A1A1A),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 5),

                  Text(
                    "$coins",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: quizCompleted
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 100,
                    ),

                    const SizedBox(height: 25),

                    Text(
                      "🎉 Quiz Completed!",
                      style: GoogleFonts.orbitron(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Thank you for playing today's GTA 6 Quiz!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Come back tomorrow for a brand new set of questions.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onBackHome();
                      },
                      icon: const Icon(Icons.home),
                      label: const Text("Back to Home"),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/quiz_bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.65)),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          "Question ${currentQuestionIndex + 1}/${todayQuestions.length}",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // progress bar
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(20),
                          child: LinearProgressIndicator(
                            value:
                                (currentQuestionIndex + 1) /
                                todayQuestions.length,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade800,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.pinkAccent,
                            ),
                          ),
                        ),

                        SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xff1A1A1A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentQuestion.question,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        Expanded(
                          child: ListView.builder(
                            itemCount: currentQuestion.options.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: ElevatedButton(
                                  onPressed: answerSelected
                                      ? null
                                      : () {
                                          setState(() {
                                            selectedAnswer = index;
                                            answerSelected = true;
                                            if (index ==
                                                currentQuestion.answerIndex) {
                                              answeredCorrect = true;
                                              score++;
                                              coins += 100;
                                              saveQuizProgress();
                                            } else {
                                              answeredCorrect = false;
                                            }
                                          });
                                        },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: getOptionColor(index),
                                    disabledBackgroundColor: getOptionColor(
                                      index,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      currentQuestion.options[index],
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (answerSelected && !rewardClaimed)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: showRewardedAd,

                                // Rewarded Ad code will go here
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  answeredCorrect
                                      ? "🎁 Watch Ad & Get 2× Coins"
                                      : "🎁 Watch Ad & Get 100 Coins",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 15),

                        if (answerSelected)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                currentQuestionIndex ==
                                        todayQuestions.length - 1
                                    ? "Finish Quiz"
                                    : "Next Question",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
}
