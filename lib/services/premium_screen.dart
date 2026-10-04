import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gta_6_comapnion_app/services/premium_cinematics_screen.dart';
import 'package:gta_6_comapnion_app/services/premium_cinematics_service.dart';
import 'package:gta_6_comapnion_app/services/premium_state.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String get _storeName =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'App Store' : 'Google Play';

  List<dynamic> _previewVideos = [];
  bool _loadingVideos = true;

  @override
  void initState() {
    super.initState();
    premiumState.addListener(_onPremiumChanged);
    premiumState.initialize();
    _loadPreviewVideos();
  }

  void _onPremiumChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPreviewVideos() async {
    try {
      final videos = await PremiumCinematicsService().fetchCinematics();
      if (!mounted) return;
      setState(() {
        _previewVideos = videos.take(3).toList();
        _loadingVideos = false;
      });
    } catch (e) {
      debugPrint('Premium preview error: $e');
      if (!mounted) return;
      setState(() => _loadingVideos = false);
    }
  }

  @override
  void dispose() {
    premiumState.removeListener(_onPremiumChanged);
    super.dispose();
  }

  void _openCinematics() {
    if (!premiumState.isPremium) {
      _showUnlockMessage();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumCinematicsScreen()),
    );
  }

  void _showUnlockMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔒 Unlock GTA 6 PRO to watch Pro Cinematics.'),
        backgroundColor: Color(0xFF151521),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = premiumState.premiumProduct;
    final isPremium = premiumState.isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFF050611),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080914),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'GTA 6 PRO',
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.8,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _hero(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _benefitCard(
                      Icons.movie_creation_rounded,
                      'EXCLUSIVE\nCINEMATICS',
                      'Premium GTA 6 videos',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _benefitCard(
                      Icons.block_rounded,
                      'ZERO\nADS',
                      'No interruptions',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _payOnceCard(),
              const SizedBox(height: 16),
              if (!isPremium) ...[
                _purchaseCard(product),
                TextButton(
                  onPressed: premiumState.isLoading
                      ? null
                      : premiumState.restorePurchases,
                  child: Text(
                    'Restore Purchase',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ] else ...[
                _activeCard(),
                const SizedBox(height: 12),
                _watchButton(),
              ],
              const SizedBox(height: 18),
              _cinematicHeader(),
              const SizedBox(height: 7),
              _cinematicPreview(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white30,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Secure payment through $_storeName',
                    style: GoogleFonts.poppins(
                      color: Colors.white30,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              if (premiumState.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    premiumState.errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.orange,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFFF2DA6).withValues(alpha: .65),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF1493).withValues(alpha: .20),
            blurRadius: 30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/gta6cover2.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF140016),
                      Color(0xFF6B087A),
                      Color(0xFF102B75),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: .88),
                    Colors.black.withValues(alpha: .35),
                    Colors.black.withValues(alpha: .76),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFFF4DA6),
                    size: 23,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'UPGRADE TO',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              top: 58,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'GTA 6 ',
                      style: GoogleFonts.bebasNeue(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'PRO',
                      style: GoogleFonts.bebasNeue(
                        color: const Color(0xFFFF4DA6),
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 22,
              top: 125,
              right: 20,
              child: Text(
                'MORE THAN A COMPANION\nA VIP EXPERIENCE',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.65,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Row(
                children: [
                  Expanded(child: _heroPill(Icons.movie_rounded, 'PRO CINEMATICS')),
                  const SizedBox(width: 8),
                  Expanded(child: _heroPill(Icons.block_rounded, 'ZERO ADS')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .48),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFFF4DA6), size: 16),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitCard(IconData icon, String title, String description) {
    return Container(
      height: 142,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0D19),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFF8338EC).withValues(alpha: .30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFFF4DA6), size: 34),
          const SizedBox(height: 9),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  Widget _payOnceCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0E1C),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFF8338EC).withValues(alpha: .35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF006E).withValues(alpha: .12),
            ),
            child: const Icon(Icons.verified_rounded, color: Color(0xFFFF4DA6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAY ONCE • KEEP PRO',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'One-time purchase with lifetime access.',
                  style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _purchaseCard(dynamic product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF006E), Color(0xFF8338EC), Color(0xFF3A86FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF006E).withValues(alpha: .25),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.diamond_rounded, color: Colors.white, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GET GTA 6 PRO',
                      style: GoogleFonts.bebasNeue(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'ONE-TIME PURCHASE • LIFETIME ACCESS',
                      style: GoogleFonts.orbitron(
                        color: Colors.white.withValues(alpha: .88),
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            product?.price ??
                (premiumState.isLoading ? 'Loading price...' : 'Price shown by $_storeName'),
            style: GoogleFonts.bebasNeue(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'NO SUBSCRIPTION • NO MONTHLY FEE',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: .78),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: premiumState.isLoading
                  ? null
                  : premiumState.buyPremium,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF8B168F),
                disabledBackgroundColor: Colors.white54,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: premiumState.isLoading
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF8B168F),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'UNLOCK GTA 6 PRO',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF16C784).withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF16C784).withValues(alpha: .55),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Color(0xFF16C784), size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GTA 6 PRO ACTIVE',
                  style: GoogleFonts.bebasNeue(
                    color: const Color(0xFF16C784),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Pro Cinematics + zero ads are unlocked.',
                  style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _watchButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _openCinematics,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4DA6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill_rounded),
            const SizedBox(width: 8),
            Text(
              'WATCH PRO CINEMATICS',
              style: GoogleFonts.bebasNeue(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cinematicHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'PREMIUM CINEMATICS',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
        ),
        TextButton(
          onPressed: _openCinematics,
          child: Text(
            'SEE ALL →',
            style: GoogleFonts.orbitron(
              color: const Color(0xFFFF4DA6),
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _cinematicPreview() {
    if (_loadingVideos) {
      return Container(
        height: 145,
        decoration: BoxDecoration(
          color: const Color(0xFF0C0E1C),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF4DA6),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_previewVideos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0E1C),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'Exclusive Pro Cinematics will appear here.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
        ),
      );
    }

    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _previewVideos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final video = _previewVideos[index];
          final locked = !premiumState.isPremium;

          return GestureDetector(
            onTap: locked ? _showUnlockMessage : _openCinematics,
            child: Container(
              width: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF0C0E1C),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF8338EC).withValues(alpha: .35),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          video.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF22002D), Color(0xFF152A72)],
                              ),
                            ),
                            child: const Icon(
                              Icons.movie_rounded,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        ),
                        Container(
                          color: locked
                              ? Colors.black.withValues(alpha: .58)
                              : Colors.black.withValues(alpha: .25),
                        ),
                        Center(
                          child: Container(
                            width: locked ? 48 : 44,
                            height: locked ? 48 : 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: .72),
                              border: Border.all(
                                color: locked
                                    ? const Color(0xFFFF4DA6)
                                    : Colors.white.withValues(alpha: .45),
                                width: 1.4,
                              ),
                            ),
                            child: Icon(
                              locked
                                  ? Icons.lock_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: locked ? 21 : 29,
                            ),
                          ),
                        ),
                        if (locked)
                          Positioned(
                            top: 9,
                            right: 9,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF006E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PRO ONLY',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .4,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.bebasNeue(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (locked)
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFFFF4DA6),
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
