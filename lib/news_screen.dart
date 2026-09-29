import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gta_6_comapnion_app/services/premium_state.dart';
import 'package:gta_6_comapnion_app/services/ad_manager.dart';
import 'news_model.dart';
import 'news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();

  // ============================================================
  // NEWS DATA
  // ============================================================

  List<News> _allNews = [];
  List<News> _filteredNews = [];

  bool _isLoading = true;
  String? _error;

  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Official',
    'Gameplay',
    'Characters',
    'Vehicles',
    'Rumor',
    'Leaks',
    'News',
  ];

  // ============================================================
  // ADMOB NATIVE ADS
  // ============================================================

  final List<NativeAd?> _nativeAds = [];

  // Tracks which ad positions are actually loaded.
  final Set<int> _loadedNativeAds = {};

  // Prevents old/disposed ad callbacks from affecting new ads.
  int _nativeAdGeneration = 0;

  // Every 5th news tap shows an interstitial.
  int _newsTapCount = 0;

  static const String _nativeAdUnitId =
      'ca-app-pub-7694497723149363/4612546853';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  // ============================================================
  // LOAD NEWS
  // ============================================================

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final news = await _newsService.fetchNews();

      if (!mounted) return;

      _allNews = news;
      _applyCategoryFilter();

      if (!premiumState.isPremium) {
        _prepareNativeAds();
      } else {
        _disposeNativeAds();
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('NEWS SCREEN ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Unable to load news right now.';
      });
    }
  }

  // ============================================================
  // CATEGORY FILTER
  // ============================================================

  void _applyCategoryFilter() {
    if (_selectedCategory == 'All') {
      _filteredNews = List.from(_allNews);
    } else {
      _filteredNews = _allNews
          .where(
            (news) =>
                news.category.toLowerCase() ==
                _selectedCategory.toLowerCase(),
          )
          .toList();
    }
  }

  void _selectCategory(String category) {
    if (_selectedCategory == category) return;

    setState(() {
      _selectedCategory = category;
      _applyCategoryFilter();
    });

    if (!premiumState.isPremium) {
      _prepareNativeAds();
    }
  }

  // ============================================================
  // FEATURED NEWS
  // ============================================================

  News? get _featuredNews {
    try {
      return _allNews.firstWhere(
        (news) => news.isFeatured,
      );
    } catch (_) {
      return _allNews.isNotEmpty
          ? _allNews.first
          : null;
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} day'
          '${difference.inDays == 1 ? '' : 's'} ago';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // OPEN ARTICLE
  // ============================================================

  void _openArticle(News news) {
    if (premiumState.isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewsDetailsScreen(news: news),
        ),
      );
      return;
    }

    _newsTapCount++;
    debugPrint('NEWS TAP COUNT: $_newsTapCount');

    if (_newsTapCount >= 5) {
      _newsTapCount = 0;

      AdManager.showInterstitial(
        onFinished: () {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewsDetailsScreen(news: news),
            ),
          );
        },
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsDetailsScreen(news: news),
      ),
    );
  }

  // ============================================================
  // PREPARE NATIVE ADS
  // ============================================================

  void _prepareNativeAds() {
    _disposeNativeAds();

    if (premiumState.isPremium) {
      return;
    }

    final int generation = _nativeAdGeneration;

    // One ad after every 3 news cards.
    //
    // 3 news  = 1 ad
    // 6 news  = 2 ads
    // 9 news  = 3 ads
    final int adCount = _filteredNews.length ~/ 3;

    // Create empty positions.
    _nativeAds.addAll(
      List<NativeAd?>.filled(
        adCount,
        null,
      ),
    );

    for (int i = 0; i < adCount; i++) {
      final NativeAd nativeAd = NativeAd(
        adUnitId: _nativeAdUnitId,
        factoryId: 'newsNativeAd',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            // Ignore old callbacks.
            if (!mounted ||
                generation != _nativeAdGeneration) {
              ad.dispose();
              return;
            }

            if (i >= _nativeAds.length) {
              ad.dispose();
              return;
            }

            final loadedAd = ad as NativeAd;

            // Replace only this position.
            _nativeAds[i]?.dispose();

            _nativeAds[i] = loadedAd;
            _loadedNativeAds.add(i);

            debugPrint(
              'NEWS NATIVE ${i + 1} LOADED',
            );

            if (mounted) {
              setState(() {});
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint(
              'NEWS NATIVE ${i + 1} FAILED: '
              '${error.message}',
            );

            ad.dispose();

            if (!mounted ||
                generation != _nativeAdGeneration) {
              return;
            }

            if (i < _nativeAds.length) {
              _nativeAds[i] = null;
              _loadedNativeAds.remove(i);
            }

            if (mounted) {
              setState(() {});
            }
          },
        ),
      );

      nativeAd.load();
    }
  }

  // ============================================================
  // NATIVE AD WIDGET
  // ============================================================

  Widget _buildNewsNativeAd(int adIndex) {
    if (premiumState.isPremium) {
      return const SizedBox.shrink();
    }

    if (adIndex < 0 ||
        adIndex >= _nativeAds.length) {
      return const SizedBox.shrink();
    }

    // DO NOT show AdWidget before loading.
    if (!_loadedNativeAds.contains(adIndex)) {
      return const SizedBox.shrink();
    }

    final NativeAd? ad = _nativeAds[adIndex];

    if (ad == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AdWidget(
            ad: ad,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE NATIVE ADS
  // ============================================================

  void _disposeNativeAds() {
    // Invalidate all previous callbacks.
    _nativeAdGeneration++;

    for (final ad in _nativeAds) {
      ad?.dispose();
    }

    _nativeAds.clear();
    _loadedNativeAds.clear();
  }

  @override
  void dispose() {
    _disposeNativeAds();
    super.dispose();
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: false,
        title: Text(
          'LATEST NEWS',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadNews,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.pink,
        backgroundColor: const Color(0xFF1A1A1A),
        onRefresh: _loadNews,
        child: _buildBody(),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 250),
          Center(
            child: CircularProgressIndicator(
              color: Colors.pink,
            ),
          ),
        ],
      );
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 180),
          const Icon(
            Icons.cloud_off,
            size: 60,
            color: Colors.white54,
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    // ----------------------------------------------------------
    // EMPTY
    // ----------------------------------------------------------

    if (_allNews.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 220),
          Center(
            child: Icon(
              Icons.article_outlined,
              size: 65,
              color: Colors.white38,
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: Text(
              'No news available yet.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 17,
              ),
            ),
          ),
        ],
      );
    }

    final featured = _featuredNews;

    // ----------------------------------------------------------
    // NEWS BODY
    // ----------------------------------------------------------

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        bottom: 30,
      ),
      children: [
        // FEATURED
        if (featured != null) ...[
          _sectionTitle('FEATURED'),
          _buildFeaturedCard(featured),
        ],

        const SizedBox(height: 20),

        // CATEGORIES
        _sectionTitle('CATEGORIES'),
        _buildCategorySelector(),

        const SizedBox(height: 20),

        // NEWS HEADER
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            children: [
              Text(
                _selectedCategory == 'All'
                    ? 'ALL NEWS'
                    : _selectedCategory.toUpperCase(),
                style: GoogleFonts.orbitron(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_filteredNews.length} articles',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // NEWS LIST + NATIVE ADS
        if (_filteredNews.isEmpty)
          _buildNoCategoryNews()
        else
          ...List.generate(
            _filteredNews.length,
            (index) {
              final news = _filteredNews[index];

              return Column(
                children: [
                  _buildNewsCard(news),

                  // Native ad after:
                  // News 3 -> Ad 1
                  // News 6 -> Ad 2
                  // News 9 -> Ad 3
                  if ((index + 1) % 3 == 0)
                    _buildNewsNativeAd(
                      (index + 1) ~/ 3 - 1,
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        12,
      ),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.pink,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY SELECTOR
  // ============================================================

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: _categories.length,
        separatorBuilder: (_, __) {
          return const SizedBox(
            width: 8,
          );
        },
        itemBuilder: (context, index) {
          final category = _categories[index];

          final selected =
              category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              _selectCategory(category);
            },
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 200,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.pink
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(
                  22,
                ),
                border: Border.all(
                  color: selected
                      ? Colors.pink
                      : Colors.white12,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // FEATURED CARD
  // ============================================================

  Widget _buildFeaturedCard(News news) {
    return GestureDetector(
      onTap: () {
        _openArticle(news);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            22,
          ),
          color: const Color(0xFF1D1D1D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.4,
              ),
              blurRadius: 15,
              offset: const Offset(
                0,
                8,
              ),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(
              news.imageUrl,
              height: 260,
            ),

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xEE000000),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: const Text(
                  'FEATURED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _categoryBadge(news.category),

                  const SizedBox(height: 8),

                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          news.source,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        '•',
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        _formatDate(
                          news.publishedAt,
                        ),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NEWS CARD
  // ============================================================

  Widget _buildNewsCard(News news) {
    return GestureDetector(
      onTap: () {
        _openArticle(news);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              child: _buildImage(
                news.imageUrl,
                width: 120,
                height: 125,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _categoryBadge(news.category),

                    const SizedBox(height: 8),

                    Text(
                      news.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      news.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            news.source,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                            ),
                          ),
                        ),

                        Text(
                          _formatDate(
                            news.publishedAt,
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _buildImage(
    String? imageUrl, {
    double? width,
    double? height,
  }) {
    if (imageUrl == null ||
        imageUrl.trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFF242424),
        child: const Center(
          child: Icon(
            Icons.article,
            color: Colors.white30,
            size: 42,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFF242424),
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.white30,
              size: 40,
            ),
          ),
        );
      },
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          width: width,
          height: height,
          color: const Color(0xFF242424),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.pink,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CATEGORY BADGE
  // ============================================================

  Widget _categoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(
          0.15,
        ),
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          color: Colors.pink,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ============================================================
  // NO CATEGORY NEWS
  // ============================================================

  Widget _buildNoCategoryNews() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 80,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.filter_alt_off,
            size: 50,
            color: Colors.white30,
          ),

          const SizedBox(height: 12),

          Text(
            'No $_selectedCategory news available.',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// NEWS DETAILS SCREEN
// ================================================================

class NewsDetailsScreen extends StatelessWidget {
  final News news;

  const NewsDetailsScreen({
    super.key,
    required this.news,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          'NEWS',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ARTICLE IMAGE
            if (news.imageUrl != null &&
                news.imageUrl!.trim().isNotEmpty)
              Image.network(
                news.imageUrl!,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 240,
                    color: const Color(0xFF242424),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white30,
                        size: 50,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                color: const Color(0xFF242424),
                child: const Center(
                  child: Icon(
                    Icons.article,
                    color: Colors.white30,
                    size: 60,
                  ),
                ),
              ),

            // ARTICLE CONTENT
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // CATEGORY
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(
                        0.15,
                      ),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Text(
                      news.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.pink,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // TITLE
                  Text(
                    news.title,
                    style: GoogleFonts.orbitron(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // SOURCE + DATE
                  Row(
                    children: [
                      const Icon(
                        Icons.source,
                        size: 16,
                        color: Colors.white54,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          news.source,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        '•',
                        style: TextStyle(
                          color: Colors.white30,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        _formatDate(
                          news.publishedAt,
                        ),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // DESCRIPTION
                  Text(
                    news.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Divider(
                    color: Colors.white12,
                  ),

                  const SizedBox(height: 20),

                  // FULL ARTICLE
                  Text(
                    news.articleContent,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}