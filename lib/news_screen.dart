import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gta_6_comapnion_app/services/premium_state.dart';
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
  // ADMOB BANNER
  // ============================================================

  // Each ad position gets its own BannerAd instance.
  // Reusing the same AdWidget in multiple places causes:
  // "This AdWidget is already in the Widget Tree".
  final List<BannerAd?> _bannerAds = [];

  // Google official TEST banner ID.
  //
  // IMPORTANT:
  // Replace this with your real News Banner Ad Unit ID
  // before production release.
  static const String _bannerAdUnitId =
      'ca-app-pub-7694497723149363/2711425799';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadNews();

    // Banner ads are prepared after the news list is loaded,
    // because we need one unique BannerAd for every 3 cards.
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
        _prepareBannerAds();
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
                news.category.toLowerCase() == _selectedCategory.toLowerCase(),
          )
          .toList();
    }
  }

  void _selectCategory(String category) {
    _selectedCategory = category;
    _applyCategoryFilter();

    if (!premiumState.isPremium) {
      _prepareBannerAds();
    }

    setState(() {});
  }

  // ============================================================
  // FEATURED NEWS
  // ============================================================

  News? get _featuredNews {
    try {
      return _allNews.firstWhere((news) => news.isFeatured);
    } catch (_) {
      return _allNews.isNotEmpty ? _allNews.first : null;
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsDetailsScreen(news: news)),
    );
  }

  // ============================================================
  // ADMOB - PREPARE BANNERS
  // ============================================================

  void _prepareBannerAds() {
    // Premium users should never load or display news ads.
    if (premiumState.isPremium) {
      _disposeBannerAds();
      return;
    }

    _disposeBannerAds();

    // One ad after every 3 news cards:
    // 3 cards -> 1 ad
    // 6 cards -> 2 ads
    // 9 cards -> 3 ads
    final adCount = _filteredNews.length ~/ 3;

    for (int i = 0; i < adCount; i++) {
      final ad = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('NEWS BANNER ${i + 1} LOADED');

            if (!mounted) return;

            setState(() {});
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('NEWS BANNER ${i + 1} FAILED: ${error.message}');

            final failedIndex = _bannerAds.indexOf(ad as BannerAd?);

            ad.dispose();

            if (failedIndex != -1) {
              _bannerAds[failedIndex] = null;
            }

            if (!mounted) return;

            setState(() {});
          },
        ),
      );

      _bannerAds.add(ad);
      ad.load();
    }
  }

  // ============================================================
  // ADMOB - BANNER WIDGET
  // ============================================================

  Widget _buildNewsBannerAd(int adIndex) {
    if (premiumState.isPremium) {
      return const SizedBox.shrink();
    }

    if (adIndex < 0 || adIndex >= _bannerAds.length) {
      return const SizedBox.shrink();
    }

    final ad = _bannerAds[adIndex];

    if (ad == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              'ADVERTISEMENT',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 4),

            SizedBox(
              width: ad.size.width.toDouble(),
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void _disposeBannerAds() {
    for (final ad in _bannerAds) {
      ad?.dispose();
    }

    _bannerAds.clear();
  }

  @override
  void dispose() {
    _disposeBannerAds();
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
            icon: const Icon(Icons.refresh),
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

          Center(child: CircularProgressIndicator(color: Colors.pink)),
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

          const Icon(Icons.cloud_off, size: 60, color: Colors.white54),

          const SizedBox(height: 20),

          Center(
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
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
              style: TextStyle(color: Colors.white70, fontSize: 17),
            ),
          ),
        ],
      );
    }

    // ----------------------------------------------------------
    // NEWS BODY
    // ----------------------------------------------------------

    final featured = _featuredNews;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30),

      children: [
        // ------------------------------------------------------
        // FEATURED
        // ------------------------------------------------------
        if (featured != null) ...[
          _sectionTitle('FEATURED'),

          _buildFeaturedCard(featured),
        ],

        const SizedBox(height: 20),

        // ------------------------------------------------------
        // CATEGORIES
        // ------------------------------------------------------
        _sectionTitle('CATEGORIES'),

        _buildCategorySelector(),

        const SizedBox(height: 20),

        // ------------------------------------------------------
        // NEWS HEADER
        // ------------------------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

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

                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ------------------------------------------------------
        // NEWS LIST + ADS
        // ------------------------------------------------------
        if (_filteredNews.isEmpty)
          _buildNoCategoryNews()
        else
          ...List.generate(_filteredNews.length, (index) {
            final news = _filteredNews[index];

            return Column(
              children: [
                _buildNewsCard(news),

                // Show a unique banner after every 3 cards.
                //
                // index 0 = card 1
                // index 1 = card 2
                // index 2 = card 3 -> AD #1
                //
                // index 5 = card 6 -> AD #2
                // index 8 = card 9 -> AD #3
                if ((index + 1) % 3 == 0)
                  _buildNewsBannerAd((index + 1) ~/ 3 - 1),
              ],
            );
          }),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),

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

        padding: const EdgeInsets.symmetric(horizontal: 16),

        itemCount: _categories.length,

        separatorBuilder: (_, __) {
          return const SizedBox(width: 8);
        },

        itemBuilder: (context, index) {
          final category = _categories[index];

          final selected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              _selectCategory(category);
            },

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),

              decoration: BoxDecoration(
                color: selected ? Colors.pink : const Color(0xFF1E1E1E),

                borderRadius: BorderRadius.circular(22),

                border: Border.all(
                  color: selected ? Colors.pink : Colors.white12,
                ),
              ),

              child: Text(
                category,

                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,

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
        margin: const EdgeInsets.symmetric(horizontal: 16),

        height: 260,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),

          color: const Color(0xFF1D1D1D),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),

              blurRadius: 15,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        clipBehavior: Clip.antiAlias,

        child: Stack(
          fit: StackFit.expand,

          children: [
            _buildImage(news.imageUrl, height: 260),

            // Dark gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,

                  end: Alignment.bottomCenter,

                  colors: [Colors.transparent, Color(0xEE000000)],
                ),
              ),
            ),

            // Featured badge
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

                  borderRadius: BorderRadius.circular(20),
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

            // Featured content
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

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

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Text('•', style: TextStyle(color: Colors.white54)),

                      const SizedBox(width: 8),

                      Text(
                        _formatDate(news.publishedAt),

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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),

        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: Colors.white10),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),

              child: _buildImage(news.imageUrl, width: 120, height: 125),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(13),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

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

                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                            ),
                          ),
                        ),

                        Text(
                          _formatDate(news.publishedAt),

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

  Widget _buildImage(String? imageUrl, {double? width, double? height}) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        width: width,
        height: height,

        color: const Color(0xFF242424),

        child: const Center(
          child: Icon(Icons.article, color: Colors.white30, size: 42),
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

      loadingBuilder: (context, child, loadingProgress) {
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.15),

        borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.symmetric(vertical: 80),

      child: Column(
        children: [
          const Icon(Icons.filter_alt_off, size: 50, color: Colors.white30),

          const SizedBox(height: 12),

          Text(
            'No $_selectedCategory news available.',

            style: const TextStyle(color: Colors.white60, fontSize: 15),
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

  const NewsDetailsScreen({super.key, required this.news});

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

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
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // ARTICLE IMAGE
            // ==================================================
            if (news.imageUrl != null && news.imageUrl!.trim().isNotEmpty)
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
                  child: Icon(Icons.article, color: Colors.white30, size: 60),
                ),
              ),

            // ==================================================
            // ARTICLE CONTENT
            // ==================================================
            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.15),

                      borderRadius: BorderRadius.circular(8),
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

                  // Title
                  Text(
                    news.title,

                    style: GoogleFonts.orbitron(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Source + Date
                  Row(
                    children: [
                      const Icon(Icons.source, size: 16, color: Colors.white54),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          news.source,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Text('•', style: TextStyle(color: Colors.white30)),

                      const SizedBox(width: 12),

                      Text(
                        _formatDate(news.publishedAt),

                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Description
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

                  const Divider(color: Colors.white12),

                  const SizedBox(height: 20),

                  // Full article
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
