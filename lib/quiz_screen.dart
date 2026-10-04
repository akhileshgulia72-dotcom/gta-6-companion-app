import 'dart:math';
import 'package:gta_6_comapnion_app/rewarded_ad_service.dart';
import 'package:gta_6_comapnion_app/services/premium_state.dart';
import 'package:gta_6_comapnion_app/services/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:gta_6_comapnion_app/questions.dart';
import 'package:gta_6_comapnion_app/services/analytics_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class QuizScreen extends StatefulWidget {
  final VoidCallback onBackHome;

  const QuizScreen({
    super.key,
    required this.onBackHome,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // ============================================================
  // ADS
  // ============================================================

  InterstitialAd? interstitialAd;
  bool isInterstitialReady = false;

  // ============================================================
  // QUIZ
  // ============================================================

  bool quizCompleted = false;

  int coins = 0;

  late List<Question> todayQuestions;
  late Question currentQuestion;

  int currentQuestionIndex = 0;

  int? selectedAnswer;

  bool answeredCorrect = false;
  bool rewardClaimed = false;
  bool answerSelected = false;

  int score = 0;

  // ============================================================
  // STREAK
  // ============================================================

  int streak = 0;
  int highestStreak = 0;

  String badge = "No Badge Yet";

  int streakReward = 0;
  String streakBadge = "";

  // ============================================================
  // INTERSTITIAL AD
  // ============================================================

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
      adUnitId:
          AdManager.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isInterstitialReady = true;
        },
        onAdFailedToLoad: (error) {
          isInterstitialReady = false;
          debugPrint(
            "Interstitial ad error: $error",
          );
        },
      ),
    );
  }

  // ============================================================
  // REWARDED AD
  // ============================================================

  Future<void> showRewardedAd() async {
    if (!mounted) return;

    await RewardedAdService.showRewardedAd(
      onReward: () async {
        if (!mounted) return;

        setState(() {
          rewardClaimed = true;
          coins += 100;
        });

        await saveQuizProgress();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 You earned 100 Coins!',
            ),
          ),
        );
      },
      onAdPreparing: () {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Preparing your reward…',
              ),
            ),
          );
      },
      onAdNotReady: () {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Rewarded video is not ready yet. Please try again in a moment.',
              ),
            ),
          );
      },
    );
  }

  // ============================================================
  // SHOW INTERSTITIAL
  // ============================================================

  void showInterstitialAd() {
    if (premiumState.isPremium) return;
    if (interstitialAd == null) {
      return;
    }

    interstitialAd!.show();

    interstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();

        interstitialAd = null;
        isInterstitialReady = false;

        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent:
          (ad, error) {
        ad.dispose();

        interstitialAd = null;
        isInterstitialReady = false;

        loadInterstitialAd();
      },
    );
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  String getTodayDate() {
    final now = DateTime.now();

    return "${now.year}-${now.month}-${now.day}";
  }

  String getYesterdayDate() {
    final yesterday =
        DateTime.now().subtract(
      const Duration(days: 1),
    );

    return "${yesterday.year}-${yesterday.month}-${yesterday.day}";
  }

  // ============================================================
  // LOAD QUESTION INDEX
  // ============================================================

  Future<void> loadQuestionIndex() async {
    final prefs =
        await SharedPreferences.getInstance();

    final String today = getTodayDate();

    final String savedDate =
        prefs.getString("quizDate") ?? "";

    // New day
    if (savedDate != today) {
      await prefs.setString(
        "quizDate",
        today,
      );

      await prefs.setBool(
        "quizCompleted",
        false,
      );

      await prefs.setInt(
        "questionIndex",
        0,
      );

      await prefs.setBool(
        "answerSelected",
        false,
      );

      await prefs.setInt(
        "selectedAnswer",
        -1,
      );

      await prefs.setBool(
        "answeredCorrect",
        false,
      );
    }

    final bool completed =
        prefs.getBool("quizCompleted") ??
            false;

    if (completed) {
      if (!mounted) return;

      setState(() {
        quizCompleted = true;
      });

      return;
    }

    currentQuestionIndex =
        prefs.getInt("questionIndex") ?? 0;

    if (currentQuestionIndex >=
        todayQuestions.length) {
      currentQuestionIndex = 0;
    }

    if (!mounted) return;

    setState(() {
      currentQuestion =
          todayQuestions[currentQuestionIndex];
    });
  }

  // ============================================================
  // SAVE QUIZ PROGRESS
  // ============================================================

  Future<void> saveQuizProgress() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      "coins",
      coins,
    );

    await prefs.setInt(
      "questionIndex",
      currentQuestionIndex,
    );

    await prefs.setBool(
      "answerSelected",
      answerSelected,
    );

    await prefs.setInt(
      "selectedAnswer",
      selectedAnswer ?? -1,
    );

    await prefs.setBool(
      "answeredCorrect",
      answeredCorrect,
    );

    await prefs.setString(
      "quizDate",
      getTodayDate(),
    );
  }

  // ============================================================
  // LOAD COINS
  // ============================================================

  Future<void> loadCoins() async {
    final prefs =
        await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      coins =
          prefs.getInt("coins") ?? 0;
    });
  }

  // ============================================================
  // GET BADGE
  // ============================================================

  String getBadgeForStreak(
    int currentStreak,
  ) {
    if (currentStreak >= 7) {
      return "🏆 7-Day Legend";
    }

    switch (currentStreak) {
      case 1:
        return "🔥 Streak Starter";

      case 2:
        return "⚔️ 2-Day Warrior";

      case 3:
        return "🔥 3-Day Grinder";

      case 4:
        return "⚡ 4-Day Hunter";

      case 5:
        return "💎 5-Day Elite";

      case 6:
        return "👑 6-Day Master";

      default:
        return "No Badge Yet";
    }
  }

  // ============================================================
  // LOAD QUIZ PROGRESS
  // ============================================================

  Future<void> loadQuizProgress() async {
    final prefs =
        await SharedPreferences.getInstance();

    final int savedHighestStreak =
        prefs.getInt(
              "highestQuizStreak",
            ) ??
            0;

    final int savedStreak =
        prefs.getInt(
              "quizStreak",
            ) ??
            0;

    final String savedBadge =
        getBadgeForStreak(
      savedHighestStreak,
    );

    final int savedStreakReward =
        prefs.getInt(
              "lastStreakReward",
            ) ??
            0;

    final String savedStreakBadge =
        prefs.getString(
              "lastStreakBadge",
            ) ??
            "";

    if (!mounted) return;

    setState(() {
      coins =
          prefs.getInt("coins") ?? 0;

      streak = savedStreak;

      highestStreak =
          savedHighestStreak;

      badge = savedBadge;

      streakReward =
          savedStreakReward;

      streakBadge =
          savedStreakBadge;

      currentQuestionIndex =
          prefs.getInt(
                "questionIndex",
              ) ??
              0;

      answerSelected =
          prefs.getBool(
                "answerSelected",
              ) ??
              false;

      final int savedAnswer =
          prefs.getInt(
                "selectedAnswer",
              ) ??
              -1;

      selectedAnswer =
          savedAnswer == -1
              ? null
              : savedAnswer;

      answeredCorrect =
          prefs.getBool(
                "answeredCorrect",
              ) ??
              false;

      // Only set current question when
      // today's quiz is not already completed.
      final bool completed =
          prefs.getBool(
                "quizCompleted",
              ) ??
              false;

      if (!completed &&
          currentQuestionIndex <
              todayQuestions.length) {
        currentQuestion =
            todayQuestions[
                currentQuestionIndex];
      }
    });
  }

  // ============================================================
  // COMPLETE DAILY STREAK
  // ============================================================

  Future<void> completeDailyStreak() async {
    final prefs =
        await SharedPreferences.getInstance();

    final String today =
        getTodayDate();

    final String yesterday =
        getYesterdayDate();

    final String lastStreakDate =
        prefs.getString(
              "lastStreakDate",
            ) ??
            "";

    int currentStreak =
        prefs.getInt(
              "quizStreak",
            ) ??
            0;

    // ==========================================================
    // PREVENT DOUBLE REWARD
    // ==========================================================

    if (lastStreakDate == today) {
      streak = currentStreak;

      streakReward =
          prefs.getInt(
                "lastStreakReward",
              ) ??
              0;

      streakBadge =
          prefs.getString(
                "lastStreakBadge",
              ) ??
              getBadgeForStreak(
                currentStreak,
              );

      return;
    }

    // ==========================================================
    // CONTINUE OR RESET STREAK
    // ==========================================================

    if (lastStreakDate == yesterday) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }

    // ==========================================================
    // REWARD
    // ==========================================================

    final int cycleDay =
    ((currentStreak - 1) % 7) + 1;

final int reward;

switch (cycleDay) {
  case 1:
    reward = 100;
    break;

  case 2:
    reward = 200;
    break;

  case 3:
    reward = 300;
    break;

  case 4:
    reward = 400;
    break;

  case 5:
    reward = 500;
    break;

  case 6:
    reward = 600;
    break;

  case 7:
    reward = 1000;
    break;

  default:
    reward = 100;
}

    // ==========================================================
    // BADGE
    // ==========================================================

    final String newBadge =
        getBadgeForStreak(
      currentStreak,
    );

    // ==========================================================
    // HIGHEST STREAK
    // ==========================================================

    int savedHighestStreak =
        prefs.getInt(
              "highestQuizStreak",
            ) ??
            0;

    if (currentStreak >
        savedHighestStreak) {
      savedHighestStreak =
          currentStreak;

      await prefs.setInt(
        "highestQuizStreak",
        savedHighestStreak,
      );
    }

    // ==========================================================
    // SAVE STREAK
    // ==========================================================

    await prefs.setInt(
      "quizStreak",
      currentStreak,
    );

    await prefs.setString(
      "lastStreakDate",
      today,
    );

    // Save last reward so completion
    // screen can show it after reload.
    await prefs.setInt(
      "lastStreakReward",
      reward,
    );

    await prefs.setString(
      "lastStreakBadge",
      newBadge,
    );

    // ==========================================================
    // ADD STREAK COINS
    // ==========================================================

    coins += reward;

    await prefs.setInt(
      "coins",
      coins,
    );

    if (!mounted) return;

    setState(() {
      streak = currentStreak;

      highestStreak =
          savedHighestStreak;

      badge =
          getBadgeForStreak(
        savedHighestStreak,
      );

      streakReward = reward;

      streakBadge = newBadge;
    });
  }

  // ============================================================
  // OPTION COLOR
  // ============================================================

  Color getOptionColor(int index) {
    if (!answerSelected) {
      return const Color(
        0xCC1A1A1A,
      );
    }

    if (index ==
        currentQuestion.answerIndex) {
      return Colors.green;
    }

    if (index ==
        selectedAnswer) {
      return Colors.red;
    }

    return const Color(
      0xCC1A1A1A,
    );
  }

  // ============================================================
  // NEXT QUESTION
  // ============================================================

  Future<void> nextQuestion() async {
    if (currentQuestionIndex <
        todayQuestions.length - 1) {
      currentQuestionIndex++;

      // Show interstitial every 3 questions.
      // Show interstitial every 3 questions for FREE users only.
if (!premiumState.isPremium &&
    (currentQuestionIndex + 1) % 3 == 0 &&
    isInterstitialReady) {
  showInterstitialAd();
}

      await saveQuizProgress();

      if (!mounted) return;

      setState(() {
        currentQuestion =
            todayQuestions[
                currentQuestionIndex];

        selectedAnswer = null;

        answerSelected = false;

        answeredCorrect = false;

        rewardClaimed = false;
      });
    } else {
      // ========================================================
      // QUIZ COMPLETED
      // ========================================================

      final prefs =
          await SharedPreferences.getInstance();

      // Give streak reward first.
      await completeDailyStreak();

      // Mark today's quiz completed.
      await prefs.setBool(
        "quizCompleted",
        true,
      );

      await prefs.setInt(
        "questionIndex",
        todayQuestions.length,
      );

      await prefs.setString(
        "quizDate",
        getTodayDate(),
      );

      // Clear answer state.
      await prefs.setBool(
        "answerSelected",
        false,
      );

      await prefs.setInt(
        "selectedAnswer",
        -1,
      );

      await prefs.setBool(
        "answeredCorrect",
        false,
      );

      if (!mounted) return;

      setState(() {
        quizCompleted = true;
      });
    }
  }

  // ============================================================
  // DAILY QUESTIONS
  // ============================================================

  List<Question> getTodayQuestions() {
    final now = DateTime.now();

    final seed =
        now.year * 10000 +
            now.month * 100 +
            now.day;

    final random =
        Random(seed);

    final questions =
        List<Question>.from(
      allquestions,
    );

    questions.shuffle(random);

    return questions
        .take(10)
        .toList();
  }

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Preload exactly one rewarded ad so Watch & Earn
    // can usually start immediately when the user taps it.
    RewardedAdService.preloadRewardedAd();

    premiumState.addListener(_onPremiumChanged);

    if (!premiumState.isPremium) {
      loadInterstitialAd();
    }

    todayQuestions =
        getTodayQuestions();

    currentQuestion =
        todayQuestions[0];

    AnalyticsService.quizStarted();

    loadQuestionIndex().then((_) {
      loadQuizProgress();
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    interstitialAd?.dispose();

    premiumState.removeListener(_onPremiumChanged);
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff0D0D0D),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            widget.onBackHome();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),

        title: Column(
          children: [
            Text(
              "Quiz",
              style: GoogleFonts.aboreto(
                fontSize: 30,
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              "GTA 6",
              style: GoogleFonts.orbitron(
                color:
                    Colors.pinkAccent,
                fontSize: 18,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 15,
            ),

            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),

              decoration:
                  BoxDecoration(
                color:
                    const Color(0xff1A1A1A),
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
                border: Border.all(
                  color: Colors.white24,
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    "$coins",
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: quizCompleted
          ? _buildCompletedScreen()
          : _buildQuizScreen(),
    );
  }

  // ============================================================
  // COMPLETED SCREEN
  // ============================================================

  Widget _buildCompletedScreen() {
    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 100,
            ),

            const SizedBox(height: 25),

            Text(
              "🎉 Quiz Completed!",
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 30,
                fontWeight:
                    FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // STREAK RESULT
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),

              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xffFF4DA6),
                    Color(0xff8A2BE2),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Column(
                children: [
                  const Text(
                    "🔥 DAILY STREAK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "$streak DAYS",
                    style:
                        GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "+$streakReward COINS",
                    style:
                        const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    streakBadge.isEmpty
                        ? getBadgeForStreak(
                            streak,
                          )
                        : streakBadge,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    streak >= 7
                        ? "🏆 7-Day Legend unlocked!"
                        : "Come back tomorrow to continue your streak!",
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

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

              icon:
                  const Icon(Icons.home),

              label:
                  const Text(
                "Back to Home",
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.pinkAccent,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUIZ SCREEN
  // ============================================================

  Widget _buildQuizScreen() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/quiz_bg.png',
            fit: BoxFit.cover,
          ),
        ),

        Positioned.fill(
          child: Container(
            color:
                Colors.black.withValues(alpha: 
              0.65,
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20.0),

            child: Column(
              children: [
                // ==================================================
                // QUESTION NUMBER
                // ==================================================

                Text(
                  "Question ${currentQuestionIndex + 1}/${todayQuestions.length}",
                  style:
                      GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // PROGRESS BAR
                // ==================================================

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),

                  child:
                      LinearProgressIndicator(
                    value:
                        (currentQuestionIndex +
                                1) /
                            todayQuestions
                                .length,

                    minHeight: 10,

                    backgroundColor:
                        Colors.grey.shade800,

                    valueColor:
                        const AlwaysStoppedAnimation(
                      Colors.pinkAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // QUESTION
                // ==================================================

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xff1A1A1A),

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Text(
                    currentQuestion
                        .question,

                    textAlign:
                        TextAlign.center,

                    style:
                        GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // ANSWERS
                // ==================================================

                Expanded(
                  child:
                      ListView.builder(
                    itemCount:
                        currentQuestion
                            .options
                            .length,

                    itemBuilder:
                        (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 15,
                        ),

                        child:
                            ElevatedButton(
                          onPressed:
                              answerSelected
                                  ? null
                                  : () {
                                      final bool
                                          isCorrect =
                                          index ==
                                              currentQuestion
                                                  .answerIndex;

                                      setState(
                                        () {
                                          selectedAnswer =
                                              index;

                                          answerSelected =
                                              true;

                                          if (isCorrect) {
                                            answeredCorrect =
                                                true;

                                            score++;

                                            // Existing
                                            // quiz reward.
                                            coins +=
                                                100;

                                            saveQuizProgress();
                                          } else {
                                            answeredCorrect =
                                                false;
                                          }
                                        },
                                      );

                                      AnalyticsService
                                          .questionAnswered(
                                        correct:
                                            isCorrect,
                                      );
                                    },

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                getOptionColor(
                              index,
                            ),

                            disabledBackgroundColor:
                                getOptionColor(
                              index,
                            ),

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 18,
                              horizontal: 20,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                15,
                              ),
                            ),
                          ),

                          child:
                              Align(
                            alignment:
                                Alignment
                                    .centerLeft,

                            child: Text(
                              currentQuestion
                                  .options[index],

                              style:
                                  GoogleFonts
                                      .poppins(
                                color:
                                    Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ==================================================
                // REWARDED AD
                // ==================================================

                if (answerSelected &&
                    !rewardClaimed)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 15,
                    ),

                    child:
                        SizedBox(
                      width:
                          double.infinity,

                      child:
                          ElevatedButton(
                        onPressed:
                            showRewardedAd,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.amber,

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 18,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                        ),

                        child: Text(
                          answeredCorrect
                              ? "🎁 Watch Ad & Get 2× Coins"
                              : "🎁 Watch Ad & Get 100 Coins",

                          style:
                              GoogleFonts
                                  .poppins(
                            color:
                                Colors.black,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                // ==================================================
                // NEXT / FINISH
                // ==================================================

                if (answerSelected)
                  SizedBox(
                    width:
                        double.infinity,

                    child:
                        ElevatedButton(
                      onPressed:
                          nextQuestion,

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.pinkAccent,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 18,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),

                      child: Text(
                        currentQuestionIndex ==
                                todayQuestions
                                        .length -
                                    1
                            ? "Finish Quiz"
                            : "Next Question",

                        style:
                            GoogleFonts
                                .poppins(
                          color:
                              Colors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
