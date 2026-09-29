import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// GTA 6 Companion — fully server-controlled leaderboard.
///
/// GitHub controls:
/// - weekly/all-time rankings
/// - week end time
/// - topper prize
/// - lucky draw multiplier
/// - winner announcement visibility
/// - winner details
///
/// Put this file in lib/leaderboard_screen.dart.
///
/// The app reads the JSON from GitHub, so weekly changes do not require
/// an app update.
class LeaderboardScreen extends StatefulWidget {
  final String? currentUserId;
  final String? currentUserName;

  const LeaderboardScreen({
    super.key,
    this.currentUserId,
    this.currentUserName,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  static const String leaderboardUrl =
      'https://script.google.com/macros/s/AKfycbwhl1aO-hidPhIMgSAAB2EdhY_XYUVWPv6t4Tj72upIDsnMZDMljwMqfa4JdjevGNns/exec?action=leaderboard';

  static const Color bg = Color(0xFF070811);
  static const Color panel = Color(0xFF10111D);
  static const Color panel2 = Color.fromRGBO(9, 9, 13, 1);
  static const Color pink = Color(0xFFFF4DA6);
  static const Color purple = Color(0xFF8A2BE2);
  static const Color cyan = Color(0xFF00D4FF);
  static const Color gold = Color(0xFFFFC83D);

  static const String _cacheKey = 'gta6_leaderboard_cache_v2';

  LeaderboardConfig? _config;
  bool _loading = true;
  String? _error;
  LeaderboardPeriod _period = LeaderboardPeriod.weekly;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadInitialLeaderboard();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialLeaderboard() async {
    // Show the last successful leaderboard immediately.
    final loadedFromCache = await _loadCachedLeaderboard();

    if (!mounted) return;

    if (!loadedFromCache) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    // Refresh silently in the background. The UI never waits for this.
    await _refreshLeaderboard(showLoading: !loadedFromCache);
  }

  Future<bool> _loadCachedLeaderboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return false;

      final decoded = jsonDecode(raw);
      if (decoded is! Map) return false;

      final config = LeaderboardConfig.fromJson(
        Map<String, dynamic>.from(decoded),
      );

      if (!mounted) return false;

      setState(() {
        _config = config;
        _loading = false;
        _error = null;
      });

      _startCountdown();
      return true;
    } catch (e) {
      debugPrint('Leaderboard cache read failed: $e');
      return false;
    }
  }

  Future<void> _refreshLeaderboard({bool showLoading = false}) async {
    if (!mounted) return;

    if (showLoading && _config == null) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else if (mounted) {
      setState(() => _error = null);
    }

    try {
      final response = await http
          .get(Uri.parse(leaderboardUrl))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw Exception('Invalid leaderboard response');
      }

      final map = Map<String, dynamic>.from(decoded);
      final config = LeaderboardConfig.fromJson(map);

      // Store the complete server response. This means the next opening is
      // instant even if Google Apps Script is slow or temporarily offline.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(map));

      if (!mounted) return;

      final previousVersion = _config?.leaderboardVersion;
      final changed = previousVersion == null ||
          previousVersion != config.leaderboardVersion ||
          _config?.seasonId != config.seasonId;

      setState(() {
        _config = config;
        _loading = false;
        _error = null;
      });

      _startCountdown();

      // Winner screen is server controlled. It can be enabled with
      // winner_announcement.show = true in Google Apps Script.
      if (config.winnerAnnouncement.show && changed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showWinnerOncePerSeason(config);
        });
      }
    } catch (e) {
      debugPrint('Leaderboard refresh failed: $e');

      if (!mounted) return;

      if (_config != null) {
        // Keep cached data visible. Only show a small offline notice.
        setState(() {
          _loading = false;
          _error = 'Could not refresh. Showing the latest saved leaderboard.';
        });
        return;
      }

      // No cache exists at all. Keep the existing demo fallback for
      // development/offline testing instead of leaving an endless spinner.
      setState(() {
        _config = LeaderboardConfig.demo();
        _loading = false;
        _error = 'Could not load leaderboard. Showing demo data.';
      });

      _startCountdown();
    }
  }

  Future<void> _loadLeaderboard() async {
    // Pull-to-refresh should refresh the server, but it should never hide
    // already visible cached contestants behind a loading screen.
    await _refreshLeaderboard(showLoading: _config == null);
  }

  void _startCountdown() {
    _timer?.cancel();
    _updateCountdown();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    final endsAt = _config?.weekEndsAt;
    if (endsAt == null) return;

    final difference = endsAt.difference(DateTime.now());

    if (!mounted) return;

    setState(() {
      _remaining = difference.isNegative ? Duration.zero : difference;
    });
  }

  List<LeaderboardEntry> get _entries {
    if (_config == null) return [];
    return _period == LeaderboardPeriod.weekly
        ? _config!.weekly
        : _config!.allTime;
  }

  LeaderboardEntry? get _currentUser {
    final id = widget.currentUserId?.trim();
    final name = widget.currentUserName?.trim();

    if (id != null && id.isNotEmpty) {
      for (final entry in _entries) {
        if (entry.userId == id) return entry;
      }
    }

    if (name != null && name.isNotEmpty) {
      for (final entry in _entries) {
        if (entry.name.toLowerCase() == name.toLowerCase()) return entry;
      }
    }

    return null;
  }

  Future<void> _showWinnerOncePerSeason(LeaderboardConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'winner_announcement_seen_${config.seasonId}';
    if (prefs.getBool(key) == true || !mounted) return;
    await prefs.setBool(key, true);
    if (mounted) await _openWinnerAnnouncement();
  }

  Future<void> _openWinnerAnnouncement() async {
    final winner = _config?.winnerAnnouncement;
    if (winner == null || !winner.show) return;

    await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => WinnerAnnouncementScreen(winner: winner),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: .94, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: pink,
          backgroundColor: panel,
          onRefresh: _loadLeaderboard,
          child: _loading ? const _LeaderboardLoading() : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final config = _config!;
    final entries = _entries.take(20).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(config)),
        SliverToBoxAdapter(child: _buildTabs()),
        SliverToBoxAdapter(child: _buildSeasonCard(config)),
        SliverToBoxAdapter(child: _buildRewardCard(config)),
        if (_error != null) SliverToBoxAdapter(child: _buildOfflineNotice()),
        SliverToBoxAdapter(child: _buildPodium(entries)),
        SliverToBoxAdapter(child: _buildListHeader()),
        if (entries.length <= 3)
          SliverToBoxAdapter(child: _buildEmptyMoreMessage())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final entry = entries[index + 3];
              return _buildRankRow(entry);
            }, childCount: entries.length - 3),
          ),
        if (config.winnerAnnouncement.show)
          SliverToBoxAdapter(
            child: _buildWinnerBanner(config.winnerAnnouncement),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildHeader(LeaderboardConfig config) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          _roundButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, pink],
                  ).createShader(bounds),
                  child: Text(
                    'LEADERBOARD',
                    style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  config.seasonLabel.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
          _coinBadge(),
        ],
      ),
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.045),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Icon(icon, color: Colors.white70),
      ),
    );
  }

  Widget _coinBadge() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        final coins = snapshot.data?.getInt('coins') ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.045),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: pink.withOpacity(.32)),
          ),
          child: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 5),
              Text(
                _formatNumber(coins),
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.07)),
        ),
        child: Row(
          children: [
            _tab(
              'THIS WEEK',
              _period == LeaderboardPeriod.weekly,
              () => setState(() => _period = LeaderboardPeriod.weekly),
            ),
            _tab(
              'ALL TIME',
              _period == LeaderboardPeriod.allTime,
              () => setState(() => _period = LeaderboardPeriod.allTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: [pink, purple])
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              color: selected ? Colors.white : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonCard(LeaderboardConfig config) {
    final d = _remaining.inDays;
    final h = _remaining.inHours.remainder(24);
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: pink, size: 18),
                const SizedBox(width: 7),
                Text(
                  'WEEKLY SEASON ENDS IN',
                  style: GoogleFonts.orbitron(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _timeBox(d.toString().padLeft(2, '0'), 'DAYS'),
                _plus(),
                _timeBox(h.toString().padLeft(2, '0'), 'HRS'),
                _plus(),
                _timeBox(m.toString().padLeft(2, '0'), 'MIN'),
                _plus(),
                _timeBox(s.toString().padLeft(2, '0'), 'SEC'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: pink.withOpacity(.13)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.orbitron(
                color: pink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _plus() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 5),
    child: Text('+', style: TextStyle(color: Colors.white30)),
  );

  Widget _buildRewardCard(LeaderboardConfig config) {
    final rewards = List.generate(
      5,
      (index) =>
          config.prizes[index + 1] ??
          (index == 0
              ? config.topperPrize
              : index == 1
              ? '\$5 Gift Card'
              : index == 2
              ? '\$2 Gift Card'
              : '\$1 Gift Card'),
    );

    const medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glow = .16 + (_glowController.value * .12);

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF23132C), Color(0xFF111321)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pink.withOpacity(.45)),
              boxShadow: [
                BoxShadow(
                  color: pink.withOpacity(glow),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [gold, Color(0xFFFF8C00)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🎁', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WEEKLY REWARDS',
                            style: GoogleFonts.orbitron(
                              color: gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Top 5 • Winners announced Sunday at 9:00 AM IST',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(.06)),
                  ),
                  child: Column(
                    children: List.generate(5, (index) {
                      final rank = index + 1;
                      final isLast = rank == 5;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          10,
                          index == 0 ? 9 : 7,
                          10,
                          isLast ? 9 : 7,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                medals[index],
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '#$rank',
                                style: GoogleFonts.orbitron(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                rewards[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.poppins(
                                  color: rank == 1 ? gold : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.card_giftcard, color: pink, size: 15),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Rewards are controlled from the weekly server configuration.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: pink.withOpacity(.10),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: pink.withOpacity(.22)),
                      ),
                      child: Text(
                        '${config.luckyDrawMultiplier}× DRAW',
                        style: GoogleFonts.orbitron(
                          color: pink,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfflineNotice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.orange, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error!,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> entries) {
    final top = entries.take(3).toList();

    if (top.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top.length > 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: _podiumCard(top[1], 2),
              ),
            ),
          if (top.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _podiumCard(top[0], 1),
              ),
            ),
          if (top.length > 2)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: _podiumCard(top[2], 3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _podiumCard(LeaderboardEntry entry, int rank) {
    final isFirst = rank == 1;
    final accent = rank == 1
        ? gold
        : rank == 2
        ? const Color(0xFFC7CED8)
        : const Color(0xFFCD8B63);

    return Container(
      height: isFirst ? 266 : 198,
      constraints: const BoxConstraints(minWidth: 0),
      padding: const EdgeInsets.fromLTRB(5, 9, 5, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(.13), panel.withOpacity(.98)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFirst ? gold.withOpacity(.7) : accent.withOpacity(.28),
          width: isFirst ? 1.5 : 1,
        ),
        boxShadow: isFirst
            ? [BoxShadow(color: gold.withOpacity(.12), blurRadius: 25)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isFirst)
            const Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Text('👑', style: TextStyle(fontSize: 26)),
            ),
          _rankAvatar(rank, size: isFirst ? 82 : 58, borderColor: accent),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withOpacity(.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '#$rank',
              style: GoogleFonts.orbitron(
                color: accent,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: isFirst ? 34 : 28,
            child: Text(
              entry.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: isFirst ? 11 : 8,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  _formatNumber(entry.coinsSpent),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.orbitron(
                    color: gold,
                    fontSize: isFirst ? 12 : 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'COINS SPENT',
            style: GoogleFonts.poppins(
              color: Colors.white30,
              fontSize: 7,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 2, 24, 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              'RANK',
              style: GoogleFonts.orbitron(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'PLAYER',
              style: GoogleFonts.orbitron(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            'COINS SPENT',
            style: GoogleFonts.orbitron(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankRow(LeaderboardEntry entry) {
    final isCurrent =
        _currentUser?.userId == entry.userId ||
        (_currentUser != null && _currentUser?.name == entry.name);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: isCurrent
              ? LinearGradient(
                  colors: [pink.withOpacity(.14), purple.withOpacity(.07)],
                )
              : null,
          color: isCurrent ? null : panel,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isCurrent
                ? pink.withOpacity(.5)
                : Colors.white.withOpacity(.055),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Text(
                '${entry.rank}',
                style: GoogleFonts.orbitron(
                  color: isCurrent ? pink : Colors.white70,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            _avatarForRank(entry.rank, entry.name),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  if (entry.badge.isNotEmpty)
                    Text(
                      entry.badge,
                      style: GoogleFonts.poppins(
                        color: pink,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            const Text('🪙', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              _formatNumber(entry.coinsSpent),
              style: GoogleFonts.orbitron(
                color: gold,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarForRank(int rank, String name) {
    if (rank >= 1 && rank <= 5) {
      return _rankAvatar(
        rank,
        size: 40,
        borderColor: Colors.white.withOpacity(.25),
      );
    }
    return _avatar(name);
  }

  Widget _avatar(String name) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [purple, pink]),
        border: Border.all(color: Colors.white.withOpacity(.2)),
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // Ranks 1-5 use the five fixed avatar assets.
  // The user name is always supplied by the server and is never baked into an avatar.
  Widget _rankAvatar(
    int rank, {
    required double size,
    required Color borderColor,
  }) {
    final safeRank = rank.clamp(1, 5);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/avatars/avtar_$safeRank.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [purple, pink]),
              ),
              alignment: Alignment.center,
              child: Text(
                '$safeRank',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: size * .28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildYourRank(LeaderboardEntry current) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF24112A), Color(0xFF111323)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: pink.withOpacity(.55)),
          boxShadow: [BoxShadow(color: pink.withOpacity(.12), blurRadius: 24)],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR RANK',
                  style: GoogleFonts.orbitron(
                    color: pink,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '#${current.rank}',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            _avatar(widget.currentUserName ?? current.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.currentUserName ?? current.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Keep climbing! 🚀',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'COINS SPENT',
                  style: GoogleFonts.orbitron(
                    color: pink,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatNumber(current.coinsSpent),
                  style: GoogleFonts.orbitron(
                    color: gold,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerBanner(WinnerAnnouncement winner) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _openWinnerAnnouncement,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF11121D),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gold.withOpacity(.30)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (winner.imageUrl.isNotEmpty)
                  Image.network(
                    winner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(.90),
                        Colors.black.withOpacity(.60),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 34)),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WEEKLY WINNERS',
                              style: GoogleFonts.orbitron(
                                color: gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              winner.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              winner.prize,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'VIEW WINNER POSTER  →',
                              style: GoogleFonts.orbitron(
                                color: Colors.white54,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildEmptyMoreMessage() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'No more ranked players yet.',
          style: TextStyle(color: Colors.white30),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: child,
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String _formatNumber(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buffer.write(',');
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }
}

// ---------------------------------------------------------------------------
// Winner screen
// ---------------------------------------------------------------------------

class WinnerAnnouncementScreen extends StatelessWidget {
  final WinnerAnnouncement winner;

  const WinnerAnnouncementScreen({super.key, required this.winner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060C),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.15,
                    colors: [
                      const Color(0xFF7B1FA2).withOpacity(.38),
                      const Color(0xFF05060C),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _WinnerPatternPainter()),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 58, 18, 28),
              child: Column(
                children: [
                  Text(
                    'WEEKLY WINNERS',
                    style: GoogleFonts.orbitron(
                      color: const Color(0xFFFFC83D),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SEASON RESULTS',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (winner.imageUrl.isNotEmpty)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 520),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: const Color(0xFFFFC83D).withOpacity(.45),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFC83D).withOpacity(.13),
                            blurRadius: 35,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.network(
                          winner.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const SizedBox(
                              height: 300,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFFC83D),
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => _fallbackWinnerCard(),
                        ),
                      ),
                    )
                  else
                    _fallbackWinnerCard(),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10111D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(.07)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          winner.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          winner.prize,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFC83D),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (winner.message.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            winner.message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 10,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _LeaderboardScreenState.pink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'BACK TO LEADERBOARD',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackWinnerCard() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF271035), Color(0xFF10111D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Center(
        child: Text('🏆', style: TextStyle(fontSize: 72)),
      ),
    );
  }
}

class _WinnerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.035)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x < size.width; x += 38) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

enum LeaderboardPeriod { weekly, allTime }

class LeaderboardConfig {
  final int leaderboardVersion;
  final String seasonId;
  final String seasonLabel;
  final DateTime weekEndsAt;
  final String topperPrize;
  final int luckyDrawMultiplier;
  final Map<int, String> prizes;
  final List<LeaderboardEntry> weekly;
  final List<LeaderboardEntry> allTime;
  final WinnerAnnouncement winnerAnnouncement;

  const LeaderboardConfig({
    required this.leaderboardVersion,
    required this.seasonId,
    required this.seasonLabel,
    required this.weekEndsAt,
    required this.topperPrize,
    required this.luckyDrawMultiplier,
    required this.prizes,
    required this.weekly,
    required this.allTime,
    required this.winnerAnnouncement,
  });

  factory LeaderboardConfig.fromJson(Map<String, dynamic> json) {
    List<LeaderboardEntry> parseEntries(dynamic raw) {
      if (raw is! List) return [];

      final entries = raw
          .map(
            (item) => LeaderboardEntry.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      entries.sort((a, b) => a.rank.compareTo(b.rank));
      return entries;
    }

    final winnerRaw = json['winner_announcement'];
    final winner = winnerRaw is Map
        ? WinnerAnnouncement.fromJson(Map<String, dynamic>.from(winnerRaw))
        : WinnerAnnouncement.hidden();

    return LeaderboardConfig(
      leaderboardVersion:
          int.tryParse(json['leaderboard_version']?.toString() ?? '') ?? 0,
      seasonId: json['season_id']?.toString() ?? 'current',
      seasonLabel: json['season_label']?.toString() ?? 'Weekly Season',
      weekEndsAt:
          DateTime.tryParse(json['week_ends_at']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 7)),
      topperPrize: json['topper_prize']?.toString() ?? 'Exclusive Gift Prize',
      luckyDrawMultiplier:
          int.tryParse(json['lucky_draw_multiplier']?.toString() ?? '') ?? 3,
      prizes: _parsePrizes(json['prizes']),
      weekly: parseEntries(json['weekly']),
      allTime: parseEntries(json['all_time']),
      winnerAnnouncement: winner,
    );
  }

  static Map<int, String> _parsePrizes(dynamic raw) {
    final result = <int, String>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        final rank = int.tryParse(key.toString());
        if (rank != null && rank >= 1 && rank <= 5) {
          result[rank] = value?.toString() ?? '';
        }
      });
    }
    return result;
  }

  factory LeaderboardConfig.demo() {
    return LeaderboardConfig(
      leaderboardVersion: 0,
      seasonId: 'demo',
      seasonLabel: 'Season 01',
      weekEndsAt: DateTime.now().add(const Duration(days: 2, hours: 14)),
      topperPrize: '\$10 Gift Card',
      luckyDrawMultiplier: 3,
      prizes: const {
        1: '\$10 Gift Card',
        2: '\$5 Gift Card',
        3: '\$2 Gift Card',
        4: '\$1 Gift Card',
        5: '\$1 Gift Card',
      },
      weekly: const [
        LeaderboardEntry(
          rank: 1,
          userId: 'demo-1',
          name: 'ViceCityKing',
          coinsSpent: 25480,
          badge: 'Weekly Topper',
        ),
        LeaderboardEntry(
          rank: 2,
          userId: 'demo-2',
          name: 'GTA_Legend',
          coinsSpent: 18920,
          badge: 'Pro',
        ),
        LeaderboardEntry(
          rank: 3,
          userId: 'demo-3',
          name: 'LilMiami',
          coinsSpent: 15640,
          badge: '',
        ),
        LeaderboardEntry(
          rank: 4,
          userId: 'demo-4',
          name: 'OceanDrive',
          coinsSpent: 12850,
          badge: 'Pro',
        ),
        LeaderboardEntry(
          rank: 5,
          userId: 'demo-5',
          name: 'GTA_Vibes',
          coinsSpent: 11230,
          badge: 'Pro',
        ),
        LeaderboardEntry(
          rank: 6,
          userId: 'demo-6',
          name: 'Rockstar_47',
          coinsSpent: 9870,
          badge: '',
        ),
        LeaderboardEntry(
          rank: 7,
          userId: 'demo-7',
          name: 'LosSantosKid',
          coinsSpent: 8420,
          badge: 'Pro',
        ),
        LeaderboardEntry(
          rank: 8,
          userId: 'demo-8',
          name: 'FastLane99',
          coinsSpent: 7650,
          badge: '',
        ),
      ],
      allTime: const [],
      winnerAnnouncement: WinnerAnnouncement.hidden(),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final int coinsSpent;
  final String badge;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.coinsSpent,
    required this.badge,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: int.tryParse(json['rank']?.toString() ?? '') ?? 0,
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Player',
      coinsSpent: int.tryParse(json['coins_spent']?.toString() ?? '') ?? 0,
      badge: json['badge']?.toString() ?? '',
    );
  }
}

class WinnerAnnouncement {
  final bool show;
  final String name;
  final String prize;
  final String message;
  final String imageUrl;

  const WinnerAnnouncement({
    required this.show,
    required this.name,
    required this.prize,
    required this.message,
    required this.imageUrl,
  });

  factory WinnerAnnouncement.fromJson(Map<String, dynamic> json) {
    return WinnerAnnouncement(
      show: json['show'] == true,
      name: json['name']?.toString() ?? 'Winner',
      prize: json['prize']?.toString() ?? 'Gift Prize',
      message:
          json['message']?.toString() ??
          'Congratulations to this week’s winners!',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }

  factory WinnerAnnouncement.hidden() {
    return const WinnerAnnouncement(
      show: false,
      name: '',
      prize: '',
      message: '',
      imageUrl: '',
    );
  }
}

class _LeaderboardLoading extends StatelessWidget {
  const _LeaderboardLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFFF4DA6),
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'LOADING LEADERBOARD',
            style: GoogleFonts.orbitron(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
