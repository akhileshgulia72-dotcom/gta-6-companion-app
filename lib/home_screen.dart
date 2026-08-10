
import 'package:gta_6_comapnion_app/lucky_draw_screen.dart';
import 'package:gta_6_comapnion_app/news_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gta_6_comapnion_app/charaters.dart';
import 'package:gta_6_comapnion_app/map.dart';
import 'package:gta_6_comapnion_app/news_model.dart' hide NewsService;
import 'package:gta_6_comapnion_app/quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:gta_6_comapnion_app/quiz_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _Homescrrenn();
}

class _Homescrrenn extends State<Homepage> {

InterstitialAd? interstitialAd;
bool isInterstitialReady = false;

int mapVisitCount = 0;
int earnVisitCount = 0;
int characterVisitCount = 0;

  Future<void> showWelcomePopup() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      bool dontShowAgain = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xff1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: Column(
              children: [
                const Icon(
                  Icons.card_giftcard,
                  color: Colors.amber,
                  size: 60,
                ),

                const SizedBox(height: 10),

                Text(
                  "Daily Rewards",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "🔥 Play today's GTA VI Quiz\n\n"
                  "🪙 Earn Coins\n"
                  "🏆 Participate in Lucky Draw\n"
                  "🎮 Win PlayStation 5\n"
                  "💿 Win GTA VI Ultimate Edition\n"
                  "💵 Win \$50 Gift Card",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 15),

                CheckboxListTile(
                  value: dontShowAgain,
                  activeColor: Colors.pink,
                  title: const Text(
                    "Don't show again today",
                    style: TextStyle(color: Colors.white),
                  ),
                  onChanged: (value) {
                    setState(() {
                      dontShowAgain = value!;
                    });
                  },
                ),
              ],
            ),

            actions: [

              TextButton(
                onPressed: () async {
                  if (dontShowAgain) {
                    final prefs =
                        await SharedPreferences.getInstance();

                    String today =
                        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

                    await prefs.setString(
                      "popupHiddenDate",
                      today,
                    );
                  }

                  Navigator.pop(context);
                },
                child: const Text("Later"),
              ),

             ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.pink,
  ),
  onPressed: () {
    Navigator.pop(context);

    setState(() {
      currentIndex = 2;
    });
  },
  child: const Text("Play Quiz"),
),
            ],
          );
        },
      );
    },
  );
}
Future<void> checkPopup() async {
  final prefs = await SharedPreferences.getInstance();

  String today =
      "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

  String hiddenDate =
      prefs.getString("popupHiddenDate") ?? "";

  if (hiddenDate != today) {
    Future.delayed(
      const Duration(milliseconds: 600),
      () => showWelcomePopup(),
    );
  }
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
      newsList = await NewsService().fetchNews();
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoadingNews = false;
    });
  }

  void loadRewardedAd() {
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
  void loadInterstitialAd() {
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
    loadInterstitialAd();
    loadNews();
    checkPopup();

    
    
  }

  void showRewardedAd() {
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
          ? const CharaterScreen()
          : currentIndex == 1
          ? const MapScreen()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Card(
                  elevation: 10,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadiusGeometry.all(
                          Radius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/images/gta6cover2.png",
                            width: 400,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              "COUNTDOWN TO GTA VI",
                              style: GoogleFonts.orbitron(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child:Container(
  margin: const EdgeInsets.symmetric(horizontal: 15),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFFFF006E),
        Color(0xFF8338EC),
        Color(0xFF3A86FF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(25),
    boxShadow: [
      BoxShadow(
        color: Colors.pink.withOpacity(0.6),
        blurRadius: 25,
        spreadRadius: 3,
      ),
    ],
  ),
  child: Column(
    children: [

      const Icon(
        Icons.access_time_filled,
        color: Colors.white,
        size: 45,
      ),

      const SizedBox(height: 12),

      Text(
        "COUNTDOWN TO GTA VI",
        style: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),

      const SizedBox(height: 20),

      SlideCountdown(
        duration: release.difference(DateTime.now()),
        separatorStyle: GoogleFonts.bebasNeue(
          fontSize: 55,
          color: Colors.white,
        ),
        style: GoogleFonts.bebasNeue(
          fontSize: 60,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.35),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),

      const SizedBox(height: 18),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _timeLabel("Days"),
          _timeLabel("Hours"),
          _timeLabel("Minutes"),
          _timeLabel("Seconds"),
        ],
      ),
    ],
  ),
)
                          ),

                        
                         

                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(right: 150),
                            child: Text(
                              " Latest News",
                              style: GoogleFonts.orbitron(
                                fontSize: 30,
                                fontWeight: FontWeight.bold
                              
                              
                                
                                
                              ),
                            ),
                          ),

                          isLoadingNews
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: newsList.length,
                                  itemBuilder: (context, index) {
                                    final news = newsList[index];

                                   return Card(
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  clipBehavior: Clip.antiAlias,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Image.network(
        news.image,
        width: double.infinity,
        height: 280,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 280,
          color: Colors.black26,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              news.description,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
                                  },
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: (index) {

  // Map Screen
  if (index == 1) {
    mapVisitCount++;

    if (mapVisitCount % 3 == 0 && isInterstitialReady) {
      showInterstitialAd();
    }
  }

  // Earn Coins
  if (index == 2) {
    earnVisitCount++;

    if (earnVisitCount % 4 == 0 && isInterstitialReady) {
      showInterstitialAd();
    }
  }

  // Character Screen
  if (index == 4) {
    characterVisitCount++;

    if (characterVisitCount % 4 == 0 && isInterstitialReady) {
      showInterstitialAd();
    }
  }

  setState(() {
    currentIndex = index;
  });
},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.paid), label: 'Earn Coins'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: "Lucky Draw",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Charaters'),
        ],
      ),
    );
  }
}
