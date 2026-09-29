import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:gta_6_comapnion_app/models/premium_cinematic_model.dart';
import 'package:gta_6_comapnion_app/services/premium_cinematics_service.dart';
import 'package:gta_6_comapnion_app/services/premium_state.dart';

class PremiumCinematicsScreen extends StatefulWidget {
  const PremiumCinematicsScreen({super.key});

  @override
  State<PremiumCinematicsScreen> createState() =>
      _PremiumCinematicsScreenState();
}

class _PremiumCinematicsScreenState
    extends State<PremiumCinematicsScreen> {
  late Future<List<PremiumCinematic>> _futureCinematics;

  @override
  void initState() {
    super.initState();

    _futureCinematics =
        PremiumCinematicsService().fetchCinematics();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureCinematics =
          PremiumCinematicsService().fetchCinematics();
    });

    await _futureCinematics;
  }

  @override
  Widget build(BuildContext context) {
    if (!premiumState.isPremium) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          title: const Text('PRO CINEMATICS'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            '🔒 GTA 6 PRO required',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(
          'PRO CINEMATICS',
          style: GoogleFonts.bebasNeue(
            fontSize: 26,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFFFF4DA6),
        backgroundColor: const Color(0xFF181818),
        child: FutureBuilder<List<PremiumCinematic>>(
          future: _futureCinematics,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF4DA6),
                ),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),

                  const Icon(
                    Icons.movie_outlined,
                    color: Colors.white38,
                    size: 60,
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Cinematics unavailable',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Check your internet connection and try again.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('TRY AGAIN'),
                    ),
                  ),
                ],
              );
            }

            final videos = snapshot.data ?? [];

            if (videos.isEmpty) {
              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),

                  const Icon(
                    Icons.movie_outlined,
                    color: Colors.white38,
                    size: 60,
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'More PRO CINEMATICS coming soon',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ],
              );
            }

            final featured =
                videos.where((v) => v.isFeatured).toList();

            final regular =
                videos.where((v) => !v.isFeatured).toList();

            return ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(16, 10, 16, 30),
              children: [
                Text(
                  'EXCLUSIVE FOR PRO',
                  style: GoogleFonts.bebasNeue(
                    color: const Color(0xFFFF4DA6),
                    fontSize: 27,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Watch exclusive GTA 6 cinematic content.',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),

                if (featured.isNotEmpty) ...[
                  const SizedBox(height: 22),

                  _sectionTitle('FEATURED'),

                  const SizedBox(height: 10),

                  ...featured.map(
                    (video) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: 18),
                      child: _videoCard(video),
                    ),
                  ),
                ],

                if (regular.isNotEmpty) ...[
                  const SizedBox(height: 5),

                  _sectionTitle('ALL CINEMATICS'),

                  const SizedBox(height: 10),

                  ...regular.map(
                    (video) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: 18),
                      child: _videoCard(video),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'More PRO CINEMATICS coming soon',
                    style: GoogleFonts.poppins(
                      color: Colors.white30,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.bebasNeue(
        color: Colors.white,
        fontSize: 21,
        letterSpacing: 1,
      ),
    );
  }

  Widget _videoCard(PremiumCinematic video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CinematicPlayerScreen(video: video),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                Colors.white.withValues(alpha: 0.08),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: video.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (video.thumbnailUrl.isNotEmpty)
                    Image.network(
                      video.thumbnailUrl,
                      fit: video.isVertical
                          ? BoxFit.contain
                          : BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              _thumbnailFallback(),
                    )
                  else
                    _thumbnailFallback(),

                  Container(
                    color: Colors.black.withValues(
                      alpha: 0.18,
                    ),
                  ),

                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),

                  Positioned(
                    top: 12,
                    left: 12,
                    child: _badge(
                      'PRO',
                      const Color(0xFFFF006E),
                    ),
                  ),

                  Positioned(
                    top: 12,
                    right: 12,
                    child: _badge(
                      video.isVertical
                          ? '9:16'
                          : '16:9',
                      Colors.black.withValues(
                        alpha: 0.70,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                13,
                16,
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: GoogleFonts.bebasNeue(
                      color: Colors.white,
                      fontSize: 23,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    video.subtitleText,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),

                  if (video.description.isNotEmpty) ...[
                    const SizedBox(height: 5),

                    Text(
                      video.description,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(
    String text,
    Color background,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _thumbnailFallback() {
    return Container(
      decoration:
          const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF30102B),
            Color(0xFF101020),
          ],
        ),
      ),
    );
  }
}

class CinematicPlayerScreen
    extends StatefulWidget {
  final PremiumCinematic video;

  const CinematicPlayerScreen({
    super.key,
    required this.video,
  });

  @override
  State<CinematicPlayerScreen> createState() =>
      _CinematicPlayerScreenState();
}

class _CinematicPlayerScreenState
    extends State<CinematicPlayerScreen> {
  late YoutubePlayerController _controller;

  bool get isVertical =>
      widget.video.isVertical;

  @override
  void initState() {
    super.initState();

    _controller =
        YoutubePlayerController.fromVideoId(
      videoId: widget.video.youtubeId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        playsInline: false,
        strictRelatedVideos: true,
        enableJavaScript: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    _restoreOrientation();
    super.dispose();
  }

  void _restoreOrientation() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _openFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    await SystemChrome.setPreferredOrientations(
      isVertical
          ? [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]
          : [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
    );

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _FullscreenCinematicPlayer(
          video: widget.video,
        ),
      ),
    );

    _restoreOrientation();
  }

  @override
  Widget build(BuildContext context) {
    final ratio =
        widget.video.aspectRatio;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text(
          widget.video.title,
          style: GoogleFonts.bebasNeue(
            fontSize: 24,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        children: [
          Center(
            child: Container(
              color: Colors.black,
              constraints: BoxConstraints(
                maxWidth:
                    isVertical ? 500 : double.infinity,
              ),
              child: AspectRatio(
                aspectRatio: ratio,
                child: YoutubePlayer(
                  controller: _controller,
                  aspectRatio: ratio,
                ),
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              20,
              18,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.video.title,
                    style:
                        GoogleFonts.bebasNeue(
                      color: Colors.white,
                      fontSize: 28,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: _openFullscreen,
                  tooltip: 'Fullscreen',
                  icon: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Text(
              '${widget.video.category} • '
              '${isVertical ? 'Vertical 9:16' : 'Landscape 16:9'}',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF4DA6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (widget.video.description.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                30,
              ),
              child: Text(
                widget.video.description,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullscreenCinematicPlayer
    extends StatefulWidget {
  final PremiumCinematic video;

  const _FullscreenCinematicPlayer({
    required this.video,
  });

  @override
  State<_FullscreenCinematicPlayer> createState() =>
      _FullscreenCinematicPlayerState();
}

class _FullscreenCinematicPlayerState
    extends State<_FullscreenCinematicPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final vertical =
        widget.video.isVertical;

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    SystemChrome.setPreferredOrientations(
      vertical
          ? [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]
          : [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
    );

    _controller =
        YoutubePlayerController.fromVideoId(
      videoId: widget.video.youtubeId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
        enableCaption: true,
        playsInline: false,
        strictRelatedVideos: true,
        enableJavaScript: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          aspectRatio:
              widget.video.aspectRatio,
        ),
      ),
    );
  }
}

extension PremiumCinematicExtension
    on PremiumCinematic {
  String get subtitleText {
    if (category.trim().isEmpty) {
      return isVertical
          ? 'Vertical Cinematic'
          : 'Cinematic';
    }

    return isVertical
        ? '$category • Vertical'
        : '$category • Landscape';
  }
}