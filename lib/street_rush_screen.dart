
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rewarded_ad_service.dart';
import 'services/premium_state.dart';
import 'services/ad_manager.dart';

class StreetRushScreen extends StatefulWidget {
  const StreetRushScreen({super.key});

  @override
  State<StreetRushScreen> createState() => _StreetRushScreenState();
}

class _StreetRushScreenState extends State<StreetRushScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  final math.Random _random = math.Random();

  double _playerX = 0.5;
  double _roadOffset = 0;
  double _score = 0;
  int _coinsCollected = 0;
  int _wanted = 1;

  bool _playing = false;
  bool _gameOver = false;
  bool _reviving = false;
  bool _leftPressed = false;
  bool _rightPressed = false;

  double _elapsed = 0;
  double _spawnTimer = 0;
  double _cashTimer = 0;

  int _highScore = 0;
  int _playCount = 0;
  InterstitialAd? _interstitialAd;
  bool _interstitialLoading = false;
  bool _interstitialShowing = false;

  static const int _interstitialEveryPlays = 3;
  static String get _interstitialAdUnit => AdManager.interstitialAdUnitId;

  final List<_EnemyCar> _enemies = [];
  final List<_CashPickup> _cash = [];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _loadPlayCount();
    _ticker = createTicker(_tick);
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _highScore = prefs.getInt('streetRushHighScore') ?? 0);
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streetRushHighScore', _highScore);
  }

  Future<void> _loadPlayCount() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _playCount = prefs.getInt('streetRushPlayCount') ?? 0);
  }

  Future<void> _savePlayCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streetRushPlayCount', _playCount);
  }

  void _startGame() {
    _playCount++;
    _savePlayCount();

    setState(() {
      _playerX = 0.5;
      _roadOffset = 0;
      _score = 0;
      _coinsCollected = 0;
      _wanted = 1;
      _elapsed = 0;
      _spawnTimer = 0.6;
      _cashTimer = 0.5;
      _enemies.clear();
      _cash.clear();
      _playing = true;
      _gameOver = false;
      _reviving = false;
    });

    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    if (!_playing || _gameOver) return;

    final dt = 1 / 60.0;

    setState(() {
      final speed = 0.30 + math.min(_elapsed / 90, 0.35);
      _elapsed += dt;
      _score += dt * 18;
      _roadOffset = (_roadOffset + dt * speed) % 1;

      if (_leftPressed) _playerX -= dt * 0.85;
      if (_rightPressed) _playerX += dt * 0.85;
      _playerX = _playerX.clamp(0.18, 0.82);

      _spawnTimer -= dt;
      if (_spawnTimer <= 0) {
        _spawnEnemy();
        _spawnTimer = math.max(0.42, 1.05 - _elapsed * 0.004);
      }

      _cashTimer -= dt;
      if (_cashTimer <= 0) {
        _spawnCash();
        _cashTimer = 0.75 + _random.nextDouble() * 0.55;
      }

      for (final e in _enemies) {
        e.y += dt * speed * e.speedMultiplier;
      }

      for (final c in _cash) {
        c.y += dt * speed * 0.95;
      }

      _enemies.removeWhere((e) => e.y > 1.15);
      _cash.removeWhere((c) => c.y > 1.15);

      final playerRect = Rect.fromCenter(
        center: Offset(_playerX, 0.84),
        width: 0.13,
        height: 0.16,
      );

      for (final e in _enemies) {
        final enemyRect = Rect.fromCenter(
          center: Offset(e.x, e.y),
          width: 0.13,
          height: 0.16,
        );
        if (playerRect.overlaps(enemyRect)) {
          _finishGame();
          return;
        }
      }

      _cash.removeWhere((c) {
        final cashRect = Rect.fromCenter(
          center: Offset(c.x, c.y),
          width: 0.075,
          height: 0.055,
        );
        if (playerRect.overlaps(cashRect)) {
          _coinsCollected++;
          _score += 75;
          return true;
        }
        return false;
      });

      _wanted = math.min(5, 1 + (_elapsed ~/ 20));
    });
  }

  void _spawnEnemy() {
    final police = _random.nextDouble() < 0.25;
    _enemies.add(
      _EnemyCar(
        x: 0.18 + _random.nextDouble() * 0.64,
        y: -0.15,
        police: police,
        speedMultiplier: 0.85 + _random.nextDouble() * 0.35,
      ),
    );
  }

  void _spawnCash() {
    _cash.add(
      _CashPickup(
        x: 0.18 + _random.nextDouble() * 0.64,
        y: -0.08,
      ),
    );
  }

  void _finishGame() {
    _playing = false;
    _gameOver = true;

    final score = _score.round();
    if (score > _highScore) {
      _highScore = score;
      _saveHighScore();
    }

    if (_ticker.isActive) _ticker.stop();

    _awardCoins();

    // Show an interstitial only after every 23rd play session.
    // Premium users never receive this automatic ad.
    if (!premiumState.isPremium &&
        _playCount > 0 &&
        _playCount % _interstitialEveryPlays == 0) {
      _loadAndShowInterstitial();
    }
  }

  void _loadAndShowInterstitial() {
    if (_interstitialLoading || _interstitialShowing || !mounted) return;

    _interstitialLoading = true;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          if (!mounted || !_gameOver || premiumState.isPremium) {
            ad.dispose();
            return;
          }
          _interstitialAd?.dispose();
          _interstitialAd = ad;
          _showInterstitial();
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          debugPrint('Street Rush interstitial failed: $error');
        },
      ),
    );
  }

  void _showInterstitial() {
    final ad = _interstitialAd;
    if (ad == null || !mounted || !_gameOver || premiumState.isPremium) return;

    _interstitialAd = null;
    _interstitialShowing = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialShowing = false;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Street Rush interstitial show failed: $error');
        ad.dispose();
        _interstitialShowing = false;
      },
    );

    ad.show();
  }

  Future<void> _awardCoins() async {
    // Keeps the existing app's local coin economy simple:
    // 10 game coins for every 1,000 score, plus collected cash.
    final earned = (math.max(0, _score) ~/ 1000) * 10 + _coinsCollected;
    if (earned <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('coins') ?? 0;
    await prefs.setInt('coins', current + earned);
  }

  Future<void> _reviveWithAd() async {
    if (_reviving) return;

    setState(() => _reviving = true);

    await RewardedAdService.showRewardedAd(
      onReward: () {
        if (!mounted) return;
        setState(() {
          _reviving = false;
          _gameOver = false;
          _playing = true;
          _playerX = 0.5;
          _enemies.removeWhere((e) => e.y > 0.45);
        });
        if (!_ticker.isActive) _ticker.start();
      },
      onAdPreparing: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preparing your revive ad…'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      onAdNotReady: () {
        if (!mounted) return;
        setState(() => _reviving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rewarded ad is not ready. Try again in a moment.'),
          ),
        );
      },
    );
  }

  void _setLeft(bool value) => setState(() => _leftPressed = value);
  void _setRight(bool value) => setState(() => _rightPressed = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Street Rush',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _StreetPainter(
                  playerX: _playerX,
                  roadOffset: _roadOffset,
                  enemies: List.unmodifiable(_enemies),
                  cash: List.unmodifiable(_cash),
                  score: _score,
                  wanted: _wanted,
                ),
              ),
            ),
            if (!_playing && !_gameOver) _buildStartOverlay(),
            if (_gameOver) _buildGameOverOverlay(),
            if (_playing) _buildControls(),
            if (_playing)
              Positioned(
                top: 12,
                left: 16,
                child: _Hud(score: _score.round(), wanted: _wanted),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartOverlay() {
    return Center(
      child: _GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_car_rounded, size: 64),
            const SizedBox(height: 14),
            const Text(
              'STREET RUSH',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Drive. Collect cash. Escape the cops.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 22),
            Text('Best score: $_highScore'),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _startGame,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                child: Text('PLAY GAME'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final score = _score.round();
    final earned = (math.max(0, _score) ~/ 1000) * 10 + _coinsCollected;

    return Center(
      child: _GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BUSTED!',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text('Score  $score', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text('Cash collected  $_coinsCollected'),
            Text('Coins earned  +$earned'),
            const SizedBox(height: 8),
            Text('Best score  $_highScore'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _reviving ? null : _reviveWithAd,
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: Text(_reviving ? 'LOADING AD…' : 'WATCH AD • REVIVE'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _startGame,
              child: const Text('PLAY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ControlButton(
            icon: Icons.chevron_left_rounded,
            onDown: () => _setLeft(true),
            onUp: () => _setLeft(false),
          ),
          _ControlButton(
            icon: Icons.chevron_right_rounded,
            onDown: () => _setRight(true),
            onUp: () => _setRight(false),
          ),
        ],
      ),
    );
  }
}

class _EnemyCar {
  _EnemyCar({
    required this.x,
    required this.y,
    required this.police,
    required this.speedMultiplier,
  });

  double x;
  double y;
  bool police;
  double speedMultiplier;
}

class _CashPickup {
  _CashPickup({required this.x, required this.y});

  double x;
  double y;
}

class _Hud extends StatelessWidget {
  const _Hud({required this.score, required this.wanted});

  final int score;
  final int wanted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            Text(
              'SCORE $score',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 18),
            Text('★' * wanted, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onDown,
    required this.onUp,
  });

  final IconData icon;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(.55),
          border: Border.all(color: Colors.white30),
        ),
        child: Icon(icon, size: 44),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(26),
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        color: const Color(0xFF111522).withOpacity(.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(blurRadius: 30, spreadRadius: 2, color: Colors.black54),
        ],
      ),
      child: child,
    );
  }
}

class _StreetPainter extends CustomPainter {
  _StreetPainter({
    required this.playerX,
    required this.roadOffset,
    required this.enemies,
    required this.cash,
    required this.score,
    required this.wanted,
  });

  final double playerX;
  final double roadOffset;
  final List<_EnemyCar> enemies;
  final List<_CashPickup> cash;
  final double score;
  final int wanted;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF080A12);
    canvas.drawRect(Offset.zero & size, bg);

    final roadLeft = size.width * .10;
    final roadRight = size.width * .90;

    final cityPaint = Paint()..color = const Color(0xFF151A28);
    canvas.drawRect(
      Rect.fromLTRB(0, 0, roadLeft, size.height),
      cityPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(roadRight, 0, size.width, size.height),
      cityPaint,
    );

    final roadPaint = Paint()..color = const Color(0xFF20242D);
    canvas.drawRect(
      Rect.fromLTRB(roadLeft, 0, roadRight, size.height),
      roadPaint,
    );

    final lanePaint = Paint()
      ..color = Colors.white.withOpacity(.55)
      ..strokeWidth = 3;

    for (int lane = 1; lane < 3; lane++) {
      final x = roadLeft + (roadRight - roadLeft) * lane / 3;
      for (double y = -70 + roadOffset * 140; y < size.height; y += 140) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 65), lanePaint);
      }
    }

    // Neon city lights.
    final lightPaint = Paint()..color = const Color(0xFFFF2AA8);
    for (int i = 0; i < 18; i++) {
      final x = (i.isEven ? 28.0 : size.width - 40.0);
      final y = ((i * 73) + roadOffset * 90) % size.height;
      canvas.drawCircle(Offset(x, y), 3, lightPaint);
    }

    for (final c in cash) {
      final x = roadLeft + c.x * (roadRight - roadLeft);
      final y = c.y * size.height;
      _drawCash(canvas, Offset(x, y));
    }

    for (final e in enemies) {
      final x = roadLeft + e.x * (roadRight - roadLeft);
      final y = e.y * size.height;
      _drawCar(canvas, Offset(x, y), police: e.police);
    }

    final px = roadLeft + playerX * (roadRight - roadLeft);
    final py = size.height * .84;
    _drawCar(canvas, Offset(px, py), player: true);
  }

  void _drawCash(Canvas canvas, Offset center) {
    final p = Paint()..color = const Color(0xFF67E36F);
    final rect = Rect.fromCenter(center: center, width: 30, height: 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      p,
    );
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\$',
        style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawCar(
    Canvas canvas,
    Offset center, {
    bool player = false,
    bool police = false,
  }) {
    final body = Paint()
      ..color = player
          ? const Color(0xFFFF2AA8)
          : police
              ? const Color(0xFF3E83FF)
              : const Color(0xFFE9E9EE);

    final bodyRect = Rect.fromCenter(
      center: center,
      width: 46,
      height: 70,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(10)),
      body,
    );

    final glass = Paint()..color = const Color(0xFF10131C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -9),
          width: 30,
          height: 22,
        ),
        const Radius.circular(5),
      ),
      glass,
    );

    final light = Paint()..color = Colors.white;
    canvas.drawCircle(center.translate(-15, 27), 4, light);
    canvas.drawCircle(center.translate(15, 27), 4, light);

    if (police) {
      final siren = Paint()..color = const Color(0xFFFF315A);
      canvas.drawRect(
        Rect.fromCenter(
          center: center.translate(0, -31),
          width: 16,
          height: 5,
        ),
        siren,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StreetPainter oldDelegate) => true;
}
