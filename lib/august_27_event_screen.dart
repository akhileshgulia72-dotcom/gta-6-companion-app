import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'explore_screen.dart';
import 'models/august_event_model.dart';
import 'services/august_event_service.dart';

class August27EventScreen extends StatefulWidget {
  const August27EventScreen({super.key});

  @override
  State<August27EventScreen> createState() =>
      _August27EventScreenState();
}

class _August27EventScreenState
    extends State<August27EventScreen> {
  final AugustEventService _eventService =
      AugustEventService();

  AugustEventModel? _event;

  YoutubePlayerController? _youtubeController;

  Timer? _timer;

  Duration _remaining = Duration.zero;

  bool _isLoading = true;
  bool _isMuted = false;

  final GlobalKey _trailerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final event = await _eventService.getEvent();

      _setupEvent(event);
    } catch (_) {
      _setupEvent(
        AugustEventModel.fromJson({
          'event_enabled': true,
          'event_date': '2026-08-27T00:00:00',
          'event_status': 'COUNTDOWN ACTIVE',
          'event_label': 'SPECIAL EVENT',
          'event_title': 'COUNTDOWN TO GTA VI',
          'event_live_title': 'THE EVENT IS LIVE',
          'event_subtitle':
              'Something special is coming on August 27.',
          'event_live_subtitle':
              'The wait is over. Explore the latest GTA 6 content.',
          'trailer_video_id': 'VQRLujxTm3c',
          'event_intel_enabled': true,
          'event_intel_title': 'VICE CITY TRANSMISSION',
          'event_intel_text':
              'Stay connected. New information and updates may arrive during this special GTA 6 event.',
          'latest_updates_enabled': true,
          'watch_trailer_enabled': true,
          'explore_enabled': true,
          'latest_updates_title': 'LATEST',
          'latest_updates_subtitle': 'UPDATES',
          'watch_title': 'WATCH',
          'watch_subtitle': 'TRAILER',
          'explore_title': 'EXPLORE',
          'explore_subtitle': 'GTA 6',
        }),
      );
    }
  }

  void _setupEvent(AugustEventModel event) {
    _event = event;

    _youtubeController =
        YoutubePlayerController.fromVideoId(
      videoId: event.trailerVideoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        privacyEnhancedMode: true,
      ),
    );

    _updateCountdown();

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  void _updateCountdown() {
    if (_event == null) return;

    final difference =
        _event!.eventDate.difference(DateTime.now());

    if (!mounted) return;

    setState(() {
      _remaining =
          difference.isNegative ? Duration.zero : difference;
    });

    if (difference.isNegative) {
      _timer?.cancel();
    }
  }

  bool get _eventLive => _remaining == Duration.zero;

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  Future<void> _toggleSound() async {
    final controller = _youtubeController;

    if (controller == null) return;

    if (_isMuted) {
      await controller.unMute();
    } else {
      await controller.mute();
    }

    if (!mounted) return;

    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _watchTrailer() {
    final trailerContext =
        _trailerKey.currentContext;

    if (trailerContext != null) {
      Scrollable.ensureVisible(
        trailerContext,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }

    Future.delayed(
      const Duration(milliseconds: 750),
      () {
        _youtubeController?.playVideo();
      },
    );
  }

  void _openExplore() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExploreScreen(),
      ),
    );
  }

  void _openLatestUpdates() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _event == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF05050A),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF4DA6),
          ),
        ),
      );
    }

    if (!_event!.eventEnabled) {
      return Scaffold(
        backgroundColor: const Color(0xFF05050A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF05050A),
        ),
        body: Center(
          child: Text(
            'This event is currently unavailable.',
            style: GoogleFonts.poppins(
              color: Colors.white70,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF05050A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/august_27_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.20),
                    const Color(0xFF05050A).withOpacity(0.80),
                    const Color(0xFF05050A),
                  ],
                  stops: const [
                    0.0,
                    0.30,
                    0.68,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),

                Expanded(
                  child: SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      40,
                    ),
                    child: Column(
                      children: [
                        _buildStatus(),

                        const SizedBox(height: 28),

                        _buildHero(),

                        const SizedBox(height: 20),

                        _buildEventDate(),

                        const SizedBox(height: 28),

                        _eventLive
                            ? _buildLiveEvent()
                            : _buildCountdown(),

                        const SizedBox(height: 24),

                        if (_event!.eventIntelEnabled)
                          _buildEventIntel(),

                        if (_event!.eventIntelEnabled)
                          const SizedBox(height: 24),

                        _buildTrailer(),

                        const SizedBox(height: 24),

                        _buildActionButtons(),

                        const SizedBox(height: 28),

                        _buildContinueButton(),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      child: Row(
        children: [
          _circleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.40),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFFF4DA6)
                    .withOpacity(0.60),
              ),
            ),
            child: Text(
              _eventLive
                  ? '● EVENT LIVE'
                  : '● AUG 27 EVENT',
              style: GoogleFonts.poppins(
                color: _eventLive
                    ? const Color(0xFF00E5A0)
                    : const Color(0xFFFF78B8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const Spacer(),

          _circleButton(
            icon: _isMuted
                ? Icons.volume_off_rounded
                : Icons.volume_up_rounded,
            onTap: _toggleSound,
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withOpacity(0.40),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF006E).withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFFF4DA6).withOpacity(0.45),
        ),
      ),
      child: Text(
        _eventLive
            ? '● EVENT IN PROGRESS'
            : '● ${_event!.eventStatus}',
        style: GoogleFonts.poppins(
          color: const Color(0xFFFF78B8),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF006E),
                Color(0xFF8338EC),
                Color(0xFF00B4FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF006E)
                    .withOpacity(0.45),
                blurRadius: 35,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: Colors.white,
            size: 52,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          _event!.eventLabel,
          style: GoogleFonts.poppins(
            color: const Color(0xFFFF78B8),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _eventLive
              ? _event!.eventLiveTitle
              : _event!.eventTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.bebasNeue(
            fontSize: 42,
            letterSpacing: 2.5,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _eventLive
              ? _event!.eventLiveSubtitle
              : _event!.eventSubtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.5,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDate() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            color: Color(0xFF00D4FF),
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'AUGUST 27 • 2026',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes =
        _remaining.inMinutes.remainder(60);
    final seconds =
        _remaining.inSeconds.remainder(60);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF10101A)
            .withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFFF4DA6)
              .withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 25,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TIME REMAINING',
            style: GoogleFonts.poppins(
              color: const Color(0xFFFF4DA6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _timeBox(_twoDigits(days), 'DAYS'),
              _timeBox(_twoDigits(hours), 'HRS'),
              _timeBox(_twoDigits(minutes), 'MIN'),
              _timeBox(_twoDigits(seconds), 'SEC'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String value, String label) {
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.bebasNeue(
              color: Colors.white,
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveEvent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF006E),
            Color(0xFF8338EC),
            Color(0xFF0066FF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF006E)
                .withOpacity(0.35),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 46,
          ),
          const SizedBox(height: 10),
          Text(
            'THE EVENT IS LIVE!',
            style: GoogleFonts.bebasNeue(
              color: Colors.white,
              fontSize: 34,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'New GTA 6 content is now available.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventIntel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D101A)
            .withOpacity(0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF00D4FF)
              .withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF)
                      .withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: Color(0xFF00D4FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _event!.eventIntelTitle,
                  style: GoogleFonts.bebasNeue(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _event!.eventIntelText,
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailer() {
    return Container(
      key: _trailerKey,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D16)
            .withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                16,
                18,
                14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF006E)
                          .withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFFFF4DA6),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WATCH THE TRAILER',
                          style: GoogleFonts.bebasNeue(
                            color: Colors.white,
                            fontSize: 23,
                            letterSpacing: 1.4,
                          ),
                        ),
                        Text(
                          'OFFICIAL GTA VI FOOTAGE',
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      'VIDEO',
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: _youtubeController!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final buttons = <Widget>[];

    if (_event!.latestUpdatesEnabled) {
      buttons.add(
        _actionButton(
          icon: Icons.newspaper_rounded,
          title: _event!.latestUpdatesTitle,
          subtitle: _event!.latestUpdatesSubtitle,
          color: const Color(0xFFFF4DA6),
          onTap: _openLatestUpdates,
        ),
      );
    }

    if (_event!.watchTrailerEnabled) {
      buttons.add(
        _actionButton(
          icon: Icons.play_circle_fill_rounded,
          title: _event!.watchTitle,
          subtitle: _event!.watchSubtitle,
          color: const Color(0xFF00D4FF),
          onTap: _watchTrailer,
        ),
      );
    }

    if (_event!.exploreEnabled) {
      buttons.add(
        _actionButton(
          icon: Icons.explore_rounded,
          title: _event!.exploreTitle,
          subtitle: _event!.exploreSubtitle,
          color: const Color(0xFFB084FF),
          onTap: _openExplore,
        ),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          Expanded(child: buttons[i]),
          if (i != buttons.length - 1)
            const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF11111B)
                .withOpacity(0.90),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.25),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF006E),
              Color(0xFF8338EC),
              Color(0xFF0066FF),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF006E)
                  .withOpacity(0.30),
              blurRadius: 22,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _eventLive
              ? _openExplore
              : () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            _eventLive
                ? 'EXPLORE THE EVENT'
                : 'CONTINUE EXPLORING',
            style: GoogleFonts.bebasNeue(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}