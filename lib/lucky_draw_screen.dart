import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gta_6_comapnion_app/thank_you_screen.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

// ============================================================
// GITHUB CONFIG MODELS
// ============================================================

class LuckyDrawItem {
  final String id;
  final String title;
  final String subtitle;
  final int entryFee;
  final int winnerCount;
  final String emoji;

  const LuckyDrawItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.entryFee,
    required this.winnerCount,
    required this.emoji,
  });

  factory LuckyDrawItem.fromJson(Map<String, dynamic> json) {
    return LuckyDrawItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Prize',
      subtitle: json['subtitle']?.toString() ?? '',
      entryFee: int.tryParse(json['entryFee']?.toString() ?? '') ?? 0,
      winnerCount: int.tryParse(json['winnerCount']?.toString() ?? '') ?? 1,
      emoji: json['emoji']?.toString() ?? '🎁',
    );
  }
}

class LuckyDrawConfig {
  final bool enabled;
  final int configVersion;
  final List<LuckyDrawItem> draws;
  final Map<String, String> images;
  final bool winnerAnnouncementEnabled;
  final DateTime winnerDateTime;
  final String timezone;
  final List<String> rules;

  const LuckyDrawConfig({
    required this.enabled,
    required this.configVersion,
    required this.draws,
    required this.images,
    required this.winnerAnnouncementEnabled,
    required this.winnerDateTime,
    required this.timezone,
    required this.rules,
  });

  factory LuckyDrawConfig.fromJson(Map<String, dynamic> json) {
    final rawDraws = json['draws'];

    final List<LuckyDrawItem> draws = [];

    if (rawDraws is List) {
      for (final item in rawDraws) {
        if (item is Map) {
          draws.add(LuckyDrawItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final Map<String, String> images = {};

    final rawImages = json['images'];

    if (rawImages is Map) {
      rawImages.forEach((key, value) {
        images[key.toString()] = value?.toString() ?? '';
      });
    }

    final winnerRaw = json['winnerAnnouncement'] is Map
        ? Map<String, dynamic>.from(json['winnerAnnouncement'])
        : <String, dynamic>{};

    final parsedDate =
        DateTime.tryParse(winnerRaw['dateTime']?.toString() ?? '') ??
        DateTime.now();

    final List<String> rules = [];

    final rawRules = json['rules'];

    if (rawRules is List) {
      rules.addAll(rawRules.map((e) => e.toString()));
    }

    return LuckyDrawConfig(
      enabled: json['enabled'] == true,
      configVersion: int.tryParse(json['configVersion']?.toString() ?? '') ?? 1,
      draws: draws,
      images: images,
      winnerAnnouncementEnabled: winnerRaw['enabled'] == true,
      winnerDateTime: parsedDate,
      timezone: winnerRaw['timezone']?.toString() ?? 'Asia/Kolkata',
      rules: rules,
    );
  }
}

// ============================================================
// LUCKY DRAW SCREEN
// ============================================================

class LuckyDrawScreen extends StatefulWidget {
  const LuckyDrawScreen({super.key});

  @override
  State<LuckyDrawScreen> createState() => _LuckyDrawScreenState();
}

class _LuckyDrawScreenState extends State<LuckyDrawScreen> {
  // ==========================================================
  // GOOGLE APPS SCRIPT
  // ==========================================================

  static const String googleSheetUrl =
      "https://script.google.com/macros/s/AKfycbwhl1aO-hidPhIMgSAAB2EdhY_XYUVWPv6t4Tj72upIDsnMZDMljwMqfa4JdjevGNns/exec";

  // ==========================================================
  // GITHUB LUCKY DRAW CONFIG
  // ==========================================================

  static const String luckyDrawConfigUrl =
      "https://raw.githubusercontent.com/akhileshgulia72-dotcom/lucky_draw.json/main/lucky_draw.json";

  LuckyDrawConfig? luckyDrawConfig;

  bool loadingConfig = true;
  String? configError;

  // ==========================================================
  // USER DATA
  // ==========================================================

  Map<String, int> userEntries = {};

  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  int selectedEntryFee = 0;

  String selectedPrize = "";

  int userCoins = 0;

  bool acceptedPrivacyPolicy = false;

  // ==========================================================
  // SEND ENTRY TO GOOGLE SHEETS
  // ==========================================================

  Future<void> sendToGoogleSheet() async {
    try {
      final response = await http.post(
        Uri.parse(googleSheetUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "prize": selectedPrize,
          "entryFee": selectedEntryFee,
          "coinsSpent": selectedEntryFee,
        }),
      );

      debugPrint("Google Sheet Status: ${response.statusCode}");

      debugPrint("Google Sheet Response: ${response.body}");
    } catch (e) {
      debugPrint("Google Sheet Error: $e");
    }
  }

  // ==========================================================
  // LOAD GITHUB CONFIG
  // ==========================================================

  Future<void> loadLuckyDrawConfig() async {
    try {
      if (mounted) {
        setState(() {
          loadingConfig = true;
          configError = null;
        });
      }

      final response = await http
          .get(
            Uri.parse(luckyDrawConfigUrl),
            headers: {"Cache-Control": "no-cache"},
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception("GitHub returned ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception("Invalid Lucky Draw configuration");
      }

      final config = LuckyDrawConfig.fromJson(
        Map<String, dynamic>.from(decoded),
      );

      if (!mounted) return;

      setState(() {
        luckyDrawConfig = config;
        loadingConfig = false;
      });
    } catch (e) {
      debugPrint("Lucky Draw Config Error: $e");

      if (!mounted) return;

      setState(() {
        loadingConfig = false;
        configError = "Unable to load Lucky Draw configuration.";
      });
    }
  }

  // ==========================================================
  // PRIVACY POLICY
  // ==========================================================

  Future<void> openPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://akhileshgulia72-dotcom.github.io/gta6-companion-privacy-policy/',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Privacy Policy');
    }
  }

  // ==========================================================
  // LOAD COINS
  // ==========================================================

  Future<void> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      userCoins = prefs.getInt("coins") ?? 0;
    });
  }

  // ==========================================================
  // LOAD ENTRIES
  // ==========================================================

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();

    final config = luckyDrawConfig;

    if (config == null) {
      return;
    }

    final Map<String, int> entries = {};

    for (final draw in config.draws) {
      entries[draw.id] = prefs.getInt("lucky_draw_${draw.id}") ?? 0;
    }

    if (!mounted) return;

    setState(() {
      userEntries = entries;
    });
  }

  // ==========================================================
  // SAVE ENTRY
  // ==========================================================

  Future<void> saveEntry() async {
    final prefs = await SharedPreferences.getInstance();

    userCoins -= selectedEntryFee;

    await prefs.setInt("coins", userCoins);

    final draw = _findDrawByTitle(selectedPrize);

    final String entryKey = draw == null ? selectedPrize : draw.id;

    int count = userEntries[entryKey] ?? 0;

    count++;

    userEntries[entryKey] = count;

    await prefs.setInt("lucky_draw_$entryKey", count);

    await loadEntries();
    await loadCoins();
  }

  // ==========================================================
  // FIND DRAW
  // ==========================================================

  LuckyDrawItem? _findDrawByTitle(String title) {
    final config = luckyDrawConfig;

    if (config == null) return null;

    for (final draw in config.draws) {
      if (draw.title == title) {
        return draw;
      }
    }

    return null;
  }

  // ==========================================================
  // GET IMAGE
  // ==========================================================

  String _getImageUrl(LuckyDrawItem draw) {
    return luckyDrawConfig?.images[draw.id] ?? '';
  }

  // ==========================================================
  // GET COLOR
  // ==========================================================

  Color _getDrawColor(LuckyDrawItem draw) {
    switch (draw.id) {
      case "ps5":
        return Colors.orange;

      case "gta6":
        return Colors.purple;

      case "giftcard":
        return Colors.green;

      default:
        return Colors.pink;
    }
  }

  // ==========================================================
  // PARTICIPATION SHEET
  // ==========================================================

  void showParticipationSheet({required String prize, required int entryFee}) {
    final parentContext = context;
    selectedPrize = prize;
    selectedEntryFee = entryFee;
    acceptedPrivacyPolicy = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final canEnter =
                userCoins >= entryFee &&
                nameController.text.trim().isNotEmpty &&
                emailController.text.trim().isNotEmpty &&
                acceptedPrivacyPolicy;

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF111116),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF4DA6), Color(0xFF7C3AED)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.confirmation_number_outlined,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ENTER DRAW",
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  prize,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _sheetField(
                        controller: nameController,
                        label: "Full Name",
                        icon: Icons.person_outline,
                        onChanged: (_) => setModalState(() {}),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      _sheetField(
                        controller: emailController,
                        label: "Email Address",
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setModalState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.045),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            _summaryRow(
                              "Entry cost",
                              "$entryFee Coins",
                              Colors.amber,
                            ),
                            const SizedBox(height: 12),
                            _summaryRow(
                              "Your balance",
                              "$userCoins Coins",
                              userCoins >= entryFee
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                            ),
                            const SizedBox(height: 12),
                            _summaryRow(
                              "After entry",
                              "${userCoins - entryFee} Coins",
                              Colors.white70,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4DA6).withOpacity(.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFF4DA6).withOpacity(.22),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFFFF7BB8),
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Your email is used only to contact you if you win.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        value: acceptedPrivacyPolicy,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFFFF4DA6),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setModalState(() {
                            acceptedPrivacyPolicy = value ?? false;
                          });
                        },
                        title: GestureDetector(
                          onTap: openPrivacyPolicy,
                          child: const Text(
                            "I agree to the Privacy Policy",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canEnter
                                ? const Color(0xFFFF4DA6)
                                : Colors.white12,
                            foregroundColor: Colors.white,
                            elevation: canEnter ? 8 : 0,
                            shadowColor: const Color(
                              0xFFFF4DA6,
                            ).withOpacity(.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          onPressed: !canEnter
                              ? null
                              : () async {
                                  final email = emailController.text.trim();
                                  final emailRegex = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  );
                                  if (!emailRegex.hasMatch(email)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please enter a valid email address",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.pop(context);
                                  await saveEntry();
                                  sendToGoogleSheet();
                                  await loadEntries();
                                  await loadCoins();

                                  nameController.clear();
                                  emailController.clear();
                                  acceptedPrivacyPolicy = false;

                                  if (mounted) {
                                    Navigator.push(
                                      parentContext,
                                      MaterialPageRoute(
                                        builder: (_) => const ThankYouScreen(),
                                      ),
                                    );
                                  }
                                },
                          child: Text(
                            "CONFIRM ENTRY  •  $entryFee COINS",
                            style: GoogleFonts.orbitron(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autocorrect: false,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFFFF4DA6)),
        filled: true,
        fillColor: Colors.white.withOpacity(.045),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF4DA6), width: 1.5),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    loadLuckyDrawConfig();
    loadCoins();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090D),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LUCKY DRAW",
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "Exclusive rewards • Limited entries",
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 9, bottom: 9),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(.22)),
            ),
            child: Row(
              children: [
                const Icon(Icons.toll_rounded, color: Colors.amber, size: 17),
                const SizedBox(width: 6),
                Text(
                  "$userCoins",
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFF4DA6),
        backgroundColor: const Color(0xFF17171E),
        onRefresh: () async {
          await loadLuckyDrawConfig();
          await loadCoins();
          await loadEntries();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    "LIVE DRAWS",
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Colors.greenAccent, size: 7),
                        SizedBox(width: 6),
                        Text(
                          "ACTIVE",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              if (loadingConfig)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(color: Color(0xFFFF4DA6)),
                  ),
                )
              else if (configError != null)
                _stateCard(
                  icon: Icons.cloud_off_rounded,
                  title: "Unable to load draws",
                  subtitle: configError!,
                  action: "TRY AGAIN",
                  onTap: loadLuckyDrawConfig,
                )
              else if (luckyDrawConfig == null || !luckyDrawConfig!.enabled)
                _stateCard(
                  icon: Icons.pause_circle_outline_rounded,
                  title: "Draws are paused",
                  subtitle: "Please check back soon for the next reward drop.",
                )
              else if (luckyDrawConfig!.draws.isEmpty)
                _stateCard(
                  icon: Icons.card_giftcard_outlined,
                  title: "No active draws",
                  subtitle: "New rewards will appear here when they go live.",
                )
              else
                ...luckyDrawConfig!.draws.map(
                  (draw) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: buildPrizeCard(draw: draw),
                  ),
                ),
              if (luckyDrawConfig != null &&
                  luckyDrawConfig!.rules.isNotEmpty) ...[
                const SizedBox(height: 5),
                _buildRules(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF21152C), Color(0xFF101019), Color(0xFF171020)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4DA6).withOpacity(.10),
            blurRadius: 30,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8A2BE2).withOpacity(.13),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4DA6).withOpacity(.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFF4DA6).withOpacity(.20),
                  ),
                ),
                child: Text(
                  "REWARD DROP",
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFFFF7FBB),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Text(
                "YOUR NEXT\nBIG WIN.",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Use coins to enter exclusive draws.\nMore entries give you more chances.",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _heroStat(Icons.toll_rounded, "$userCoins", "COINS"),
                  const SizedBox(width: 10),
                  _heroStat(Icons.confirmation_number_outlined, "∞", "ENTRIES"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.04),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? action,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white30, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: onTap, child: Text(action)),
          ],
        ],
      ),
    );
  }

  Widget _buildRules() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: Color(0xFFFF4DA6),
                size: 20,
              ),
              const SizedBox(width: 9),
              Text(
                "DRAW RULES",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...luckyDrawConfig!.rules.map(rule),
        ],
      ),
    );
  }

  // ==========================================================
  // PRIZE CARD
  // ==========================================================

  Widget buildPrizeCard({required LuckyDrawItem draw}) {
    final imageUrl = _getImageUrl(draw);
    final color = _getDrawColor(draw);
    final entries = userEntries[draw.id] ?? 0;
    final winnerText = draw.winnerCount == 1
        ? "1 winner"
        : "${draw.winnerCount} winners";

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(.30)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.07),
            blurRadius: 28,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Container(
                  height: 190,
                  width: double.infinity,
                  color: Colors.black26,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              draw.emoji,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF4DA6),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            draw.emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(.75),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.55),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      winnerText.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          draw.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(draw.emoji, style: const TextStyle(fontSize: 30)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 16, 17, 17),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    draw.subtitle.isNotEmpty
                        ? draw.subtitle
                        : "Exclusive GTA VI reward",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        icon: Icons.confirmation_number_outlined,
                        label: "YOUR ENTRIES",
                        value: "$entries",
                        color: const Color(0xFFFF4DA6),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _metricCard(
                        icon: Icons.toll_rounded,
                        label: "ENTRY FEE",
                        value: "${draw.entryFee}",
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                if (luckyDrawConfig != null &&
                    luckyDrawConfig!.winnerAnnouncementEnabled) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(.045),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withOpacity(.16)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events_outlined,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "WINNER ANNOUNCEMENT",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateTime(
                                  luckyDrawConfig!.winnerDateTime,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SlideCountdown(
                          duration: _remainingDuration(
                            luckyDrawConfig!.winnerDateTime,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        "More entries = more chances to win",
                        style: TextStyle(color: Colors.white54, fontSize: 11.5),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white24,
                      size: 17,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 7,
                      shadowColor: color.withOpacity(.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      await loadCoins();
                      showParticipationSheet(
                        prize: draw.title,
                        entryFee: draw.entryFee,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_activity_outlined, size: 19),
                        const SizedBox(width: 8),
                        Text(
                          "ENTER DRAW",
                          style: GoogleFonts.orbitron(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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

  // ==========================================================
  // DATE
  // ==========================================================

  String _formatDateTime(DateTime date) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? "PM" : "AM";

    return "${date.day} "
        "${months[date.month - 1]} "
        "${date.year} • "
        "$hour:$minute $period IST";
  }

  // ==========================================================
  // COUNTDOWN
  // ==========================================================

  Duration _remainingDuration(DateTime target) {
    final difference = target.difference(DateTime.now());

    if (difference.isNegative) {
      return Duration.zero;
    }

    return difference;
  }

  // ==========================================================
  // RULE
  // ==========================================================

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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();

    super.dispose();
  }
}
