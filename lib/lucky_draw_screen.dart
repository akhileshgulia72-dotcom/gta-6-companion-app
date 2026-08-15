import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gta_6_comapnion_app/thank_you_screen.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class LuckyDrawScreen extends StatefulWidget {
  const LuckyDrawScreen({super.key});

  @override
  State<LuckyDrawScreen> createState() => _LuckyDrawScreenState();
}

class _LuckyDrawScreenState extends State<LuckyDrawScreen> {
  Future<void> sendToGoogleSheet() async {
    const url = "https://script.google.com/macros/s/AKfycbwhl1aO-hidPhIMgSAAB2EdhY_XYUVWPv6t4Tj72upIDsnMZDMljwMqfa4JdjevGNns/exec";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "prize": selectedPrize,
          "entryFee": selectedEntryFee,
          "coinsSpent": selectedEntryFee,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response: ${response.body}");
    } catch (e) {
      print("Google Sheet Error: $e");
    }
  }

  bool acceptedPrivacyPolicy = false;
  Future<void> openPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://akhileshgulia72-dotcom.github.io/gta6-companion-privacy-policy/',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Privacy Policy');
    }
  }

  Map<String, int> userEntries = {};
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  int selectedEntryFee = 0;
  String selectedPrize = "";
  int userCoins = 0;
  void showParticipationSheet({required String prize, required int entryFee}) {
     final parentContext = context;

    selectedPrize = prize;
    selectedEntryFee = entryFee;
    acceptedPrivacyPolicy = false;

     


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      prize,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Complete the details below",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),

                    const SizedBox(height: 25),

                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.pink,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.phone, color: Colors.pink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Card(
                      color: Colors.black54,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Entry Fee",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "$entryFee Coins",
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Available Coins",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "$userCoins",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "More entries = Higher chance of winning.",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        children: [
                          const TextSpan(
                            text: "By submitting your entry, you agree to our ",
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: openPrivacyPolicy,
                              child: const Text(
                                "Privacy Policy",
                                style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const TextSpan(text: "."),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    CheckboxListTile(
                      value: acceptedPrivacyPolicy,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setModalState(() {
                          acceptedPrivacyPolicy = value!;
                        });
                      },
                      activeColor: Colors.pink,
                      checkColor: Colors.white,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        "I agree to the Privacy Policy",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          if (!acceptedPrivacyPolicy) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please accept the Privacy Policy.",
                                ),
                              ),
                            );
                            return;
                          }

                          if (nameController.text.isEmpty ||
                              phoneController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all details"),
                              ),
                            );
                            return;
                          }

                          if (userCoins < selectedEntryFee) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Not enough coins")),
                            );
                            return;
                          }

                          Navigator.pop(context);

                          await saveEntry();
                          await sendToGoogleSheet();
                          await loadEntries();

                          await loadCoins();
                          nameController.clear();
                          phoneController.clear();
                          acceptedPrivacyPolicy = false;

                          Navigator.push(
                            parentContext,
                            MaterialPageRoute(
                              builder: (_) => const ThankYouScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Submit Entry",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userCoins = prefs.getInt("coins") ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    loadEntries();

    loadCoins();
  }

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userEntries["PlayStation 5"] = prefs.getInt("PlayStation 5") ?? 0;

      userEntries["GTA VI Ultimate Edition"] =
          prefs.getInt("GTA VI Ultimate Edition") ?? 0;

      userEntries["\$50 Gift Card"] = prefs.getInt("\$50 Gift Card") ?? 0;
    });
  }

  Future<void> saveEntry() async {
    final prefs = await SharedPreferences.getInstance();

    userCoins -= selectedEntryFee;
    await prefs.setInt("coins", userCoins);

    int count = userEntries[selectedPrize] ?? 0;
    count++;

    userEntries[selectedPrize] = count;
    await prefs.setInt(selectedPrize, count);

    // try {
    //   await FirebaseFirestore.instance.collection("lucky_draw_entries").add({
    //     "name": nameController.text.trim(),
    //     "phone": phoneController.text.trim(),
    //     "prize": selectedPrize,
    //     "entryFee": selectedEntryFee,
    //     "entries": 1,
    //     "coinsSpent": selectedEntryFee,
    //     "createdAt": FieldValue.serverTimestamp(),
    //   });

    //   print("Firestore Save Success");
    // } catch (e) {
    //   print("Firestore Error: $e");
    // }

    await loadEntries();
    await loadCoins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Lucky Draw",
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xffFF4DA6), Color(0xff8A2BE2)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 60,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "WIN EXCLUSIVE GTA VI REWARDS",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber),

                        const SizedBox(width: 8),

                        Text(
                          "$userCoins Coins",
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              "Available Lucky Draws",
              style: GoogleFonts.orbitron(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            buildPrizeCard(
              emoji: "🎮",
              title: "PlayStation 5",
              subtitle: "Grand Prize",
              entryFee: 10000,
              color: Colors.orange,
            ),

            const SizedBox(height: 20),

            buildPrizeCard(
              emoji: "🔥",
              title: "GTA VI Ultimate Edition",
              subtitle: "2 Winners",
              entryFee: 100,
              color: Colors.purple,
            ),

            const SizedBox(height: 20),

            buildPrizeCard(
              emoji: "💵",
              title: "\$50 Gift Card",
              subtitle: "5 Winners",
              entryFee: 5000,
              color: Colors.green,
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.pink),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lucky Draw Rules",
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  rule("Each entry costs coins."),
                  rule("More entries = Higher chance of winning."),
                  rule("Multiple entries are allowed."),
                  rule("Winner announced on result date."),
                  rule("Fake information will be disqualified."),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget buildPrizeCard({
    required String emoji,
    required String title,
    required String subtitle,
    required int entryFee,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff1C1C1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 55)),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "🎟 Your Entries: ${userEntries[title] ?? 0}",
              style: GoogleFonts.orbitron(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Entry Fee : $entryFee Coins",
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber),
            ),
            child: Column(
              children: [
                Text(
                  "🏆 Winner Announcement",
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "11 september 2026 • 08:00 PM IST",
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                SlideCountdown(
                  duration: DateTime(
                    2026,
                    09,
                    11,
                    20,
                    00,
                  ).difference(DateTime.now()),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.star, color: Colors.amber)],
          ),
          const SizedBox(height: 18),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 6),
              Text(
                "More Entries = Higher Chance of Winning",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                await loadCoins();

                showParticipationSheet(prize: title, entryFee: entryFee);
              },

              child: const Text(
                "Participate",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget rule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
