import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/gallery_model.dart';
import 'services/gallery_service.dart';

class PremiumGalleryScreen extends StatefulWidget {
  const PremiumGalleryScreen({super.key});

  @override
  State<PremiumGalleryScreen> createState() =>
      _PremiumGalleryScreenState();
}

class _PremiumGalleryScreenState extends State<PremiumGalleryScreen> {
  final GalleryService _galleryService = GalleryService();

  List<GalleryModel> _images = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final images = await _galleryService.getGalleryImages();

      if (!mounted) return;

      setState(() {
        _images = images;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _openFullScreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenGallery(
          images: _images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'GTA 6 GALLERY',
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),

      body: RefreshIndicator(
        color: const Color(0xFFFF4DA6),
        backgroundColor: const Color(0xFF1A1A1A),
        onRefresh: _loadGallery,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF4DA6),
        ),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 180),
          const Icon(
            Icons.cloud_off,
            color: Colors.white38,
            size: 60,
          ),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              'Unable to load gallery',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _loadGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4DA6),
                foregroundColor: Colors.white,
              ),
              child: const Text('TRY AGAIN'),
            ),
          ),
        ],
      );
    }

    if (_images.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Icon(
            Icons.photo_library_outlined,
            color: Colors.white38,
            size: 70,
          ),
          SizedBox(height: 15),
          Center(
            child: Text(
              'No gallery images yet.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 17,
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              20,
              18,
              15,
            ),
            child: Column(
              children: [
                Text(
                  'GTA 6 IMAGE COLLECTION',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(
                    color: const Color(0xFFFF4DA6),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_images.length} images',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            12,
            5,
            12,
            25,
          ),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final image = _images[index];

                return GestureDetector(
                  onTap: () => _openFullScreen(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.08,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          image.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFF4DA6),
                              ),
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white38,
                                size: 45,
                              ),
                            );
                          },
                        ),

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 70,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(
                                    alpha: 0.75,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          left: 10,
                          bottom: 9,
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: _images.length,
            ),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
          ),
        ),
      ],
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<GalleryModel> images;
  final int initialIndex;

  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() =>
      _FullScreenGalleryState();
}

class _FullScreenGalleryState
    extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: GoogleFonts.bebasNeue(
            fontSize: 22,
            letterSpacing: 1,
          ),
        ),
      ),

      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,

        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        itemBuilder: (context, index) {
          final image = widget.images[index];

          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                image.imageUrl,
                fit: BoxFit.contain,

                loadingBuilder:
                    (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const CircularProgressIndicator(
                    color: Color(0xFFFF4DA6),
                  );
                },

                errorBuilder:
                    (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white38,
                    size: 70,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}