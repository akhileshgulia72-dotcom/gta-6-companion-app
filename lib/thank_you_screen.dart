import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  // ===============================================================
  // TELEGRAM CHANNEL
  // ===============================================================

  static const String telegramChannelUrl =
    'https://t.me/gta6companion';

  // ===============================================================
  // OPEN TELEGRAM
  // ===============================================================

  Future<void> _openTelegramChannel(BuildContext context) async {
    final Uri url = Uri.parse(telegramChannelUrl);

    try {
      final opened = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open Telegram channel.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open Telegram.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // =====================================================
                // SUCCESS ICON
                // =====================================================

                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(.15),
                    border: Border.all(
                      color: Colors.green,
                      width: 3,
                    ),
                  ),

                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 90,
                  ),
                ),

                const SizedBox(height: 30),

                // =====================================================
                // SUCCESS TITLE
                // =====================================================

                Text(
                  "ENTRY SUCCESSFUL",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Thank you for participating in the Lucky Draw.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 30),

                // =====================================================
                // TELEGRAM PARTICIPANT CARD
                // =====================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(
                      color: const Color(0xFF229ED9),
                      width: 1.5,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF229ED9)
                            .withOpacity(.12),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      // Telegram icon
                      Container(
                        width: 60,
                        height: 60,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF229ED9)
                              .withOpacity(.15),
                        ),

                        child: const Icon(
                          Icons.send_rounded,
                          color: Color(0xFF229ED9),
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "FIND YOUR NAME",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Your participation is now visible in our "
                        "live Telegram participant list.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: const Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Color(0xFF229ED9),
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "Open our Telegram channel and "
                                "search for your name.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =====================================================
                // OPEN TELEGRAM BUTTON
                // =====================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF229ED9),

                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),

                    onPressed: () {
                      _openTelegramChannel(context);
                    },

                    icon: const Icon(
                      Icons.send_rounded,
                      size: 22,
                    ),

                    label: Text(
                      "OPEN TELEGRAM CHANNEL",
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =====================================================
                // WINNER ANNOUNCEMENT
                // =====================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius:
                        BorderRadius.circular(18),

                    border: Border.all(
                      color: Colors.pink,
                    ),
                  ),

                  child: Column(
                    children: [

                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 45,
                      ),

                     

                      const SizedBox(height: 15),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.pink
                              .withOpacity(.08),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: const Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: Colors.pink,
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "The winner will be announced "
                                "on our Telegram channel.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // =====================================================
                // ENTRY CONFIRMATION
                // =====================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: const Column(
                    children: [

                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.green,
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Your entry has been recorded.",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.amber,
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Check the live Telegram "
                              "participant list to find your name.",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.pink,
                          ),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Winner announcement will be "
                              "posted on Telegram.",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // =====================================================
                // BACK BUTTON
                // =====================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,

                      side: const BorderSide(
                        color: Colors.white30,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),

                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: Text(
                      "BACK TO LUCKY DRAW",
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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