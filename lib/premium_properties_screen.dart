import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gta_6_comapnion_app/advanced_map_screen.dart';

import 'package:gta_6_comapnion_app/services/premium_state.dart';
import 'package:gta_6_comapnion_app/services/ad_manager.dart';
class PremiumPropertiesScreen extends StatefulWidget {
  const PremiumPropertiesScreen({super.key});

  @override
  State<PremiumPropertiesScreen> createState() =>
      _PremiumPropertiesScreenState();
}

class _PremiumPropertiesScreenState
    extends State<PremiumPropertiesScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final String _propertiesUrl =
      'https://raw.githubusercontent.com/akhileshgulia72-dotcom/gta6-news-server/refs/heads/main/properties.json';

  // ============================================================
  // ADMOB
  // ============================================================

  static String get _nativeAdUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-7694497723149363/3677097458'
          : 'ca-app-pub-7694497723149363/4612546853';

  static String get _interstitialAdUnitId => AdManager.interstitialAdUnitId;

  final List<NativeAd?> _nativeAds = [];
  final List<bool> _nativeAdLoaded = [];

  InterstitialAd? _interstitialAd;

  // Click 1, 2, 3 = open normally
  // Click 4 = show interstitial and reset
  int _propertyClickCount = 0;

  List<Map<String, String>> properties = [];

  Set<String> favoriteProperties = {};

  bool showFavorites = false;
  bool _isLoading = true;

  String? _error;

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Mansion',
    'Apartment',
    'Villa',
    'Penthouse',
    'Residence',
    'Safe House',
    'Property',
    'Business',
  ];

  @override
  void initState() {
    super.initState();
    premiumState.addListener(_onPremiumChanged);

    _loadProperties();
    if (!premiumState.isPremium) {
      _loadInterstitialAd();
    }
  }

  // ============================================================
  // LOAD PROPERTIES
  // ============================================================

  Future<void> _loadProperties() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse(_propertiesUrl),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load properties: ${response.statusCode}',
        );
      }

      final List<dynamic> data =
          jsonDecode(response.body);

      final loadedProperties =
          data.map<Map<String, String>>((item) {
        final map = Map<String, dynamic>.from(item);

        return map.map(
          (key, value) {
            if (key == 'images' && value is List) {
              return MapEntry(key, jsonEncode(value));
            }

            return MapEntry(
              key,
              value?.toString() ?? '',
            );
          },
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        properties = loadedProperties;
        _isLoading = false;
      });

      await _loadFavorites();

      _prepareNativeAds();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // NATIVE ADS
  // ============================================================

  void _prepareNativeAds() {
    if (premiumState.isPremium) { _disposeNativeAds(); return; }
    _disposeNativeAds();

    // One native ad after every 3 properties.
    final adCount = properties.length ~/ 3;

    for (int i = 0; i < adCount; i++) {
      _nativeAds.add(null);
      _nativeAdLoaded.add(false);

      _loadNativeAd(i);
    }
  }

  void _loadNativeAd(int index) {
    final nativeAd = NativeAd(
      adUnitId: _nativeAdUnitId,
      factoryId: 'newsNativeAd',
      request: const AdRequest(),

      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          if (index >= _nativeAds.length) {
            ad.dispose();
            return;
          }

          setState(() {
            _nativeAds[index] = ad as NativeAd;
            _nativeAdLoaded[index] = true;
          });

          debugPrint(
            'PROPERTY NATIVE AD ${index + 1} LOADED',
          );
        },

        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'PROPERTY NATIVE AD ${index + 1} FAILED: '
            '${error.message}',
          );

          ad.dispose();

          if (!mounted) return;

          if (index < _nativeAds.length) {
            setState(() {
              _nativeAds[index] = null;
              _nativeAdLoaded[index] = false;
            });
          }
        },
      ),
    );

    nativeAd.load();
  }

  Widget _buildNativeAd(int adIndex) {
    if (adIndex < 0 ||
        adIndex >= _nativeAds.length) {
      return const SizedBox.shrink();
    }

    if (!_nativeAdLoaded[adIndex]) {
      return const SizedBox.shrink();
    }

    final ad = _nativeAds[adIndex];

    if (ad == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }

  void _disposeNativeAds() {
    for (final ad in _nativeAds) {
      ad?.dispose();
    }

    _nativeAds.clear();
    _nativeAdLoaded.clear();
  }

  // ============================================================
  // INTERSTITIAL AD
  // ============================================================

  void _onPremiumChanged() {
    if (!premiumState.isPremium) return;
    _disposeNativeAds();
    _interstitialAd?.dispose();
    _interstitialAd = null;
    if (mounted) setState(() {});
  }

  void _loadInterstitialAd() {
    if (premiumState.isPremium) return;
    if (premiumState.isPremium) return;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),

      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd?.dispose();

          _interstitialAd = ad;

          debugPrint(
            'PROPERTY INTERSTITIAL LOADED',
          );
        },

        onAdFailedToLoad: (error) {
          _interstitialAd = null;

          debugPrint(
            'PROPERTY INTERSTITIAL FAILED: '
            '${error.message}',
          );
        },
      ),
    );
  }

  // ============================================================
  // PROPERTY CLICK LOGIC
  // ============================================================

  void _handlePropertyClick(
    Map<String, String> property,
  ) {
    if (premiumState.isPremium) { _openProperty(property); return; }
    _propertyClickCount++;

    // Click 1, 2 and 3
    if (_propertyClickCount < 4) {
      _openProperty(property);
      return;
    }

    // Click 4
    _propertyClickCount = 0;

    final ad = _interstitialAd;

    if (ad == null) {
      _openProperty(property);

      _loadInterstitialAd();

      return;
    }

    _interstitialAd = null;

    ad.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();

        _loadInterstitialAd();

        _openProperty(property);
      },

      onAdFailedToShowFullScreenContent:
          (ad, error) {
        ad.dispose();

        _loadInterstitialAd();

        _openProperty(property);
      },
    );

    ad.show();
  }

  // ============================================================
  // OPEN PROPERTY DETAILS
  // ============================================================

  Future<void> _openProperty(
    Map<String, String> property,
  ) async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailsScreen(
          property: property,
        ),
      ),
    );

    if (!mounted) return;

    await _loadFavorites();
  }

  // ============================================================
  // FAVORITES
  // ============================================================

  Future<void> _loadFavorites() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedFavorites = <String>{};

    for (final property in properties) {
      final name = property['name'];

      if (name != null &&
          prefs.getBool('favorite_$name') == true) {
        savedFavorites.add(name);
      }
    }

    if (!mounted) return;

    setState(() {
      favoriteProperties = savedFavorites;
    });
  }

  // ============================================================
  // FILTERED PROPERTIES
  // ============================================================

  List<Map<String, String>>
      get filteredProperties {
    final query =
        _searchController.text
            .toLowerCase()
            .trim();

    return properties.where((property) {
      final name = property['name'] ?? '';
      final type = property['type'] ?? '';
      final location =
          property['location'] ?? '';

      final matchesFavorites =
          !showFavorites ||
              favoriteProperties.contains(name);

      final matchesCategory =
          selectedCategory == 'All' ||
              type == selectedCategory;

      final matchesSearch =
          query.isEmpty ||
              name
                  .toLowerCase()
                  .contains(query) ||
              location
                  .toLowerCase()
                  .contains(query) ||
              type
                  .toLowerCase()
                  .contains(query);

      return matchesFavorites &&
          matchesCategory &&
          matchesSearch;
    }).toList();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();

    _disposeNativeAds();

    _interstitialAd?.dispose();
    _interstitialAd = null;

    premiumState.removeListener(_onPremiumChanged);
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final filtered = filteredProperties;

    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),

      appBar: _appBar(),

      body: _buildBody(filtered),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
    List<Map<String, String>> filtered,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF4DA6),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.white38,
                size: 65,
              ),

              const SizedBox(height: 16),

              Text(
                'UNABLE TO LOAD PROPERTIES',

                textAlign:
                    TextAlign.center,

                style:
                    GoogleFonts.bebasNeue(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _error!,

                textAlign:
                    TextAlign.center,

                style:
                    GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed:
                    _loadProperties,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFFFF4DA6,
                  ),

                  foregroundColor:
                      Colors.white,
                ),

                child:
                    const Text('RETRY'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color:
          const Color(0xFFFF4DA6),

      backgroundColor:
          const Color(0xFF1A1A1A),

      onRefresh:
          _loadProperties,

      child: Column(
        children: [
          _searchBox(),

          _categorySelector(),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              4,
            ),

            child: SizedBox(
              width:
                  double.infinity,

              height: 46,

              child:
                  OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    showFavorites =
                        !showFavorites;
                  });
                },

                icon: Icon(
                  showFavorites
                      ? Icons.favorite
                      : Icons.favorite_border,

                  size: 20,
                ),

                label: Text(
                  showFavorites
                      ? 'SHOW ALL PROPERTIES'
                      : 'MY FAVORITES '
                          '(${favoriteProperties.length})',

                  style:
                      GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(
                    0xFFFF4DA6,
                  ),

                  side:
                      const BorderSide(
                    color: Color(
                      0xFFFF4DA6,
                    ),
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            child: Row(
              children: [
                Text(
                  '${filtered.length} Properties',

                  style:
                      GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      5,
                      16,
                      20,
                    ),

                    // Property 1
                    // Property 2
                    // Property 3
                    // Native Ad
                    // Property 4
                    // Property 5
                    // Property 6
                    // Native Ad

                    itemCount:
                        filtered.length +
                            (filtered.length ~/ 3),

                    itemBuilder:
                        (context, index) {
                      // Every 4th displayed item
                      // is the native ad.
                      if ((index + 1) % 4 == 0) {
                        final adIndex =
                            index ~/ 4;

                        return _buildNativeAd(
                          adIndex,
                        );
                      }

                      // Convert list index
                      // to actual property index.
                      final propertyIndex =
                          index -
                              ((index + 1) ~/ 4);

                      return _propertyCard(
                        context,
                        filtered[propertyIndex],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _appBar() {
    return AppBar(
      title: Text(
        'GTA 6 PROPERTIES',

        style:
            GoogleFonts.bebasNeue(
          fontSize: 28,
          fontWeight:
              FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),

      backgroundColor:
          Colors.transparent,

      foregroundColor:
          Colors.white,
    );
  }

  // ============================================================
  // SEARCH BOX
  // ============================================================

  Widget _searchBox() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        10,
      ),

      child: TextField(
        controller:
            _searchController,

        onChanged: (_) {
          setState(() {});
        },

        style:
            const TextStyle(
          color: Colors.white,
        ),

        decoration:
            InputDecoration(
          hintText:
              'Search properties...',

          hintStyle:
              const TextStyle(
            color: Colors.white38,
          ),

          prefixIcon:
              const Icon(
            Icons.search,
            color:
                Color(0xFF00D4FF),
          ),

          suffixIcon:
              _searchController
                      .text
                      .isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController
                            .clear();

                        setState(() {});
                      },

                      icon:
                          const Icon(
                        Icons.clear,
                        color:
                            Colors.white54,
                      ),
                    )
                  : null,

          filled: true,

          fillColor:
              Colors.white
                  .withValues(
            alpha: 0.06,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              15,
            ),

            borderSide:
                BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY SELECTOR
  // ============================================================

  Widget _categorySelector() {
    return SizedBox(
      height: 46,

      child: ListView.builder(
        scrollDirection:
            Axis.horizontal,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),

        itemCount:
            categories.length,

        itemBuilder:
            (context, index) {
          final category =
              categories[index];

          final selected =
              selectedCategory ==
                  category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory =
                    category;
              });
            },

            child: Container(
              margin:
                  const EdgeInsets.only(
                right: 8,
              ),

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),

              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xFFFF4DA6,
                      )
                    : Colors.white
                        .withValues(
                        alpha: 0.06,
                      ),

                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),

              child: Text(
                category,

                style:
                    GoogleFonts.poppins(
                  color: selected
                      ? Colors.white
                      : Colors.white60,

                  fontSize: 12,

                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PROPERTY CARD
  // ============================================================

  Widget _propertyCard(
    BuildContext context,
    Map<String, String> property,
  ) {
    return GestureDetector(
      onTap: () {
        _handlePropertyClick(property);
      },

      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 18,
        ),

        decoration:
            BoxDecoration(
          color:
              const Color(0xFF1B1B1B),

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          border: Border.all(
            color:
                Colors.white.withValues(
              alpha: 0.06,
            ),
          ),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(
                top:
                    Radius.circular(20),
              ),

              child:
                  _buildPropertyImage(
                property,
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(
                17,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property['name'] ??
                              'Unknown Property',

                          style:
                              GoogleFonts.bebasNeue(
                            fontSize: 27,

                            fontWeight:
                                FontWeight.bold,

                            color:
                                Colors.white,
                          ),
                        ),
                      ),

                      Icon(
                        favoriteProperties
                                .contains(
                          property['name'],
                        )
                            ? Icons.favorite
                            : Icons
                                .favorite_border,

                        color:
                            favoriteProperties
                                    .contains(
                          property['name'],
                        )
                                ? const Color(
                                    0xFFFF4DA6,
                                  )
                                : Colors.white38,

                        size: 23,
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color:
                            Color(0xFF00D4FF),
                        size: 16,
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          property['location'] ??
                              'Unknown Location',

                          style:
                              GoogleFonts.poppins(
                            color:
                                Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [
                      Text(
                        property['price'] ??
                            'Unknown',

                        style:
                            GoogleFonts.bebasNeue(
                          fontSize: 23,

                          color:
                              const Color(
                            0xFFFF4DA6,
                          ),

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF00D4FF,
                          ).withValues(
                            alpha: 0.1,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),

                        child: Text(
                          property['type'] ??
                              'Property',

                          style:
                              GoogleFonts.poppins(
                            color:
                                const Color(
                              0xFF00D4FF,
                            ),

                            fontSize: 11,

                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,

                    children: [
                      Text(
                        'VIEW DETAILS',

                        style:
                            GoogleFonts.bebasNeue(
                          color:
                              Colors.white70,

                          fontSize: 16,

                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(width: 6),

                      const Icon(
                        Icons.arrow_forward,
                        color:
                            Colors.white70,
                        size: 18,
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
  // PROPERTY IMAGE
  // ============================================================

  Widget _buildPropertyImage(
    Map<String, String> property,
  ) {
    final imageUrl =
        property['image_url'] ??
            property['image'] ??
            '';

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,

        height: 180,

        width:
            double.infinity,

        fit: BoxFit.cover,

        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          return _imagePlaceholder();
        },
      );
    }

    return Image.asset(
      imageUrl.isNotEmpty
          ? imageUrl
          : 'assets/images/beach_villa.png',

      height: 180,

      width:
          double.infinity,

      fit: BoxFit.cover,

      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return _imagePlaceholder();
      },
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _imagePlaceholder() {
    return Container(
      height: 180,

      width:
          double.infinity,

      color:
          const Color(0xFF1B1B1B),

      child: const Icon(
        Icons.home_work,

        color:
            Colors.white38,

        size: 60,
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          const Icon(
            Icons.search_off,
            color:
                Colors.white30,
            size: 55,
          ),

          const SizedBox(height: 12),

          Text(
            'NO PROPERTIES FOUND',

            style:
                GoogleFonts.bebasNeue(
              color:
                  Colors.white70,
              fontSize: 22,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Try another search or category.',

            style:
                GoogleFonts.poppins(
              color:
                  Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PROPERTY DETAILS SCREEN
// ============================================================================

class PropertyDetailsScreen extends StatefulWidget {
  final Map<String, String> property;

  const PropertyDetailsScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailsScreen> createState() =>
      _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool isFavorite = false;

  late final List<String> _images;
  final PageController _pageController = PageController();
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _images = _extractImages();
    _loadFavorite();
  }

  // Supports:
  // 1. images: ["url1", "url2", "url3"]
  // 2. image_url: "url1"
  // 3. old image: "assets/..."
  List<String> _extractImages() {
    final result = <String>[];

    final rawImages = widget.property['images'];

    if (rawImages != null && rawImages.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawImages);

        if (decoded is List) {
          for (final item in decoded) {
            final value = item.toString().trim();

            if (value.isNotEmpty && !result.contains(value)) {
              result.add(value);
            }
          }
        }
      } catch (_) {
        // Backward compatibility if images was supplied as comma-separated text.
        for (final value in rawImages.split(',')) {
          final image = value.trim();

          if (image.isNotEmpty && !result.contains(image)) {
            result.add(image);
          }
        }
      }
    }

    // Main image first.
    final imageUrl =
        widget.property['image_url']?.trim() ?? '';

    if (imageUrl.isNotEmpty && !result.contains(imageUrl)) {
      result.insert(0, imageUrl);
    }

    // Old image field.
    final oldImage =
        widget.property['image']?.trim() ?? '';

    if (oldImage.isNotEmpty && !result.contains(oldImage)) {
      result.add(oldImage);
    }

    // Final fallback.
    if (result.isEmpty) {
      result.add('assets/images/beach_villa.png');
    }

    return result;
  }

  Future<void> _loadFavorite() async {
    final prefs =
        await SharedPreferences.getInstance();

    final name =
        widget.property['name'] ?? '';

    if (!mounted) return;

    setState(() {
      isFavorite =
          prefs.getBool('favorite_$name') ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs =
        await SharedPreferences.getInstance();

    final name =
        widget.property['name'] ?? '';

    final newValue =
        !isFavorite;

    await prefs.setBool(
      'favorite_$name',
      newValue,
    );

    if (!mounted) return;

    setState(() {
      isFavorite = newValue;
    });
  }

  bool _isNetworkImage(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://');
  }

  Widget _imageWidget(
    String image,
    BoxFit fit, {
    double? width,
    double? height,
  }) {
    if (_isNetworkImage(image)) {
      return Image.network(
        image,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) {
          return _imagePlaceholder(
            width: width,
            height: height,
          );
        },
      );
    }

    return Image.asset(
      image,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) {
        return _imagePlaceholder(
          width: width,
          height: height,
        );
      },
    );
  }

  Widget _imagePlaceholder({
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1B1B1B),
      alignment: Alignment.center,
      child: const Icon(
        Icons.home_work,
        color: Colors.white24,
        size: 70,
      ),
    );
  }

  void _openFullScreenGallery([
    int? initialIndex,
  ]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _PropertyGalleryScreen(
          images: _images,
          initialIndex:
              initialIndex ?? _currentImage,
          propertyName:
              widget.property['name'] ??
                  'Property',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,

            backgroundColor:
                const Color(0xFF121212),

            foregroundColor:
                Colors.white,

            actions: [
              IconButton(
                onPressed:
                    _toggleFavorite,

                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,

                  color: isFavorite
                      ? const Color(0xFFFF4DA6)
                      : Colors.white,
                ),
              ),
            ],

            flexibleSpace:
                FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,

                children: [
                  // =========================================================
                  // MAIN SWIPEABLE IMAGE GALLERY
                  // =========================================================

                  GestureDetector(
                    onTap:
                        _openFullScreenGallery,

                    child:
                        PageView.builder(
                      controller:
                          _pageController,

                      itemCount:
                          _images.length,

                      onPageChanged:
                          (index) {
                        if (!mounted) {
                          return;
                        }

                        setState(() {
                          _currentImage =
                              index;
                        });
                      },

                      itemBuilder:
                          (_, index) {
                        return _imageWidget(
                          _images[index],
                          BoxFit.cover,
                        );
                      },
                    ),
                  ),

                  // =========================================================
                  // CINEMATIC GRADIENT
                  // =========================================================

                  IgnorePointer(
                    child:
                        DecoratedBox(
                      decoration:
                          BoxDecoration(
                        gradient:
                            LinearGradient(
                          begin:
                              Alignment.topCenter,
                          end:
                              Alignment.bottomCenter,

                          colors: [
                            Colors.black
                                .withValues(
                              alpha: 0.10,
                            ),

                            Colors.transparent,

                            Colors.black
                                .withValues(
                              alpha: 0.90,
                            ),
                          ],

                          stops: const [
                            0.0,
                            0.42,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // =========================================================
                  // SWIPE INDICATOR
                  // =========================================================

                  Positioned(
                    top: 85,
                    right: 16,

                    child:
                        Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.black
                            .withValues(
                          alpha: 0.58,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          30,
                        ),

                        border:
                            Border.all(
                          color: Colors.white
                              .withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),

                      child:
                          const Row(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [
                          Icon(
                            Icons
                                .photo_library_outlined,
                            color:
                                Colors.white,
                            size: 16,
                          ),

                          SizedBox(
                            width: 6,
                          ),

                          Text(
                            'SWIPE',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.w700,
                              letterSpacing:
                                  1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =========================================================
                  // PROPERTY TITLE
                  // =========================================================

                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,

                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        _statusBadge(
                          property[
                                  'status'] ??
                              'Concept',
                        ),

                        const SizedBox(
                          height: 9,
                        ),

                        Text(
                          property[
                                  'name'] ??
                              'Property',

                          style:
                              GoogleFonts
                                  .bebasNeue(
                            fontSize: 36,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.white,
                            letterSpacing:
                                1,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .location_on,
                              color:
                                  Color(
                                0xFF00D4FF,
                              ),
                              size: 17,
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Expanded(
                              child:
                                  Text(
                                property[
                                        'location'] ??
                                    'Unknown',

                                style:
                                    GoogleFonts
                                        .poppins(
                                  color:
                                      Colors.white70,
                                  fontSize:
                                      13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_images.length >
                            1) ...[
                          const SizedBox(
                            height: 10,
                          ),

                          _galleryDots(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              40,
            ),

            sliver: SliverList(
              delegate:
                  SliverChildListDelegate(
                [
                  // =========================================================
                  // THUMBNAILS
                  // =========================================================

                  if (_images.length > 1) ...[
                    _thumbnailGallery(),

                    const SizedBox(
                      height: 22,
                    ),
                  ],

                  // =========================================================
                  // PRICE
                  // =========================================================

                  _priceCard(
                    property['price'] ??
                        'Unknown',
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // =========================================================
                  // OVERVIEW
                  // =========================================================

                  _sectionTitle(
                    'PROPERTY OVERVIEW',
                    Icons.info_outline,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    property[
                            'description'] ??
                        'No description available.',

                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white70,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =========================================================
                  // INFORMATION
                  // =========================================================

                  _sectionTitle(
                    'PROPERTY INFORMATION',
                    Icons.home_work_outlined,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _infoRow(
                    Icons.category_outlined,
                    'Property Type',
                    property['type'] ??
                        'Unknown',
                  ),

                  _infoRow(
                    Icons.king_bed_outlined,
                    'Bedrooms',
                    property[
                            'bedrooms'] ??
                        'Unknown',
                  ),

                  _infoRow(
                    Icons.bathtub_outlined,
                    'Bathrooms',
                    property[
                            'bathrooms'] ??
                        'Unknown',
                  ),

                  _infoRow(
                    Icons
                        .directions_car_outlined,
                    'Garage',
                    property[
                            'garage'] ??
                        'Unknown',
                  ),

                  _infoRow(
                    Icons.pool_outlined,
                    'Pool',
                    property['pool'] ??
                        'Unknown',
                  ),

                  _infoRow(
                    Icons.security_outlined,
                    'Security',
                    property[
                            'security'] ??
                        'Unknown',
                  ),

                  _infoRow(
                    Icons.lock_outline,
                    'Privacy',
                    property[
                            'privacy'] ??
                        'Unknown',
                  ),

                  _infoRow(
                    Icons.star_outline,
                    'Best For',
                    property[
                            'bestFor'] ??
                        'Unknown',
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =========================================================
                  // FEATURES
                  // =========================================================

                  _sectionTitle(
                    'PROPERTY FEATURES',
                    Icons.auto_awesome,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _featuresCard(
                    property[
                            'features'] ??
                        '',
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =========================================================
                  // RATINGS
                  // =========================================================

                  _sectionTitle(
                    'PROPERTY RATINGS',
                    Icons.star,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _ratingCard(property),

                  const SizedBox(
                    height: 25,
                  ),

                  // =========================================================
                  // MAP
                  // =========================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,

                    child:
                        ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdvancedMapScreen(
                              focusProperty:
                                  property[
                                      'name'],
                            ),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.location_on,
                      ),

                      label: Text(
                        'VIEW ON MAP',

                        style:
                            GoogleFonts
                                .bebasNeue(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing:
                              1,
                        ),
                      ),

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF00D4FF,
                        ),

                        foregroundColor:
                            Colors.black,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // =========================================================
                  // FAVORITE
                  // =========================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,

                    child:
                        OutlinedButton.icon(
                      onPressed:
                          _toggleFavorite,

                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),

                      label: Text(
                        isFavorite
                            ? 'SAVED TO FAVORITES'
                            : 'ADD TO FAVORITES',

                        style:
                            GoogleFonts
                                .bebasNeue(
                          fontSize: 19,
                          letterSpacing:
                              1,
                        ),
                      ),

                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            const Color(
                          0xFFFF4DA6,
                        ),

                        side:
                            const BorderSide(
                          color: Color(
                            0xFFFF4DA6,
                          ),
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // =========================================================
                  // DISCLAIMER
                  // =========================================================

                  Container(
                    padding:
                        const EdgeInsets
                            .all(15),

                    decoration:
                        BoxDecoration(
                      color: Colors.blue
                          .withValues(
                        alpha: 0.06,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),

                      border:
                          Border.all(
                        color: Colors.blue
                            .withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        const Icon(
                          Icons
                              .info_outline,
                          color:
                              Colors.lightBlueAccent,
                          size: 20,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: Text(
                            'This property is presented as a '
                            'GTA 6 Companion concept. '
                            'Information marked as Concept or '
                            'Unknown should not be considered '
                            'official Rockstar Games information.',

                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  Colors.white54,
                              fontSize:
                                  11,
                              height:
                                  1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _galleryDots() {
    return Row(
      children: List.generate(
        _images.length,
        (index) => AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 220,
          ),

          margin:
              const EdgeInsets.only(
            right: 5,
          ),

          width: index ==
                  _currentImage
              ? 22
              : 7,

          height: 6,

          decoration:
              BoxDecoration(
            color: index ==
                    _currentImage
                ? const Color(
                    0xFFFF4DA6,
                  )
                : Colors.white38,

            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbnailGallery() {
    return SizedBox(
      height: 74,

      child:
          ListView.separated(
        scrollDirection:
            Axis.horizontal,

        itemCount:
            _images.length,

        separatorBuilder:
            (_, __) =>
                const SizedBox(
          width: 9,
        ),

        itemBuilder:
            (_, index) {
          final selected =
              index ==
                  _currentImage;

          return GestureDetector(
            onTap: () {
              _pageController
                  .animateToPage(
                index,
                duration:
                    const Duration(
                  milliseconds: 300,
                ),
                curve:
                    Curves.easeOutCubic,
              );
            },

            child:
                AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 220,
              ),

              width: 92,

              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),

                border:
                    Border.all(
                  color: selected
                      ? const Color(
                          0xFFFF4DA6,
                        )
                      : Colors.white12,

                  width:
                      selected ? 2 : 1,
                ),
              ),

              child:
                  ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),

                child:
                    Stack(
                  fit: StackFit.expand,

                  children: [
                    _imageWidget(
                      _images[index],
                      BoxFit.cover,
                    ),

                    if (selected)
                      Container(
                        color: Colors.black
                            .withValues(
                          alpha: 0.18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(
        color: Colors.blue
            .withValues(
          alpha: 0.18,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color: Colors
              .lightBlueAccent
              .withValues(
            alpha: 0.4,
          ),
        ),
      ),

      child: Text(
        '🔵 ${status.toUpperCase()}',

        style:
            GoogleFonts.poppins(
          color:
              Colors.lightBlueAccent,
          fontSize: 10,
          fontWeight:
              FontWeight.w700,
          letterSpacing:
              0.5,
        ),
      ),
    );
  }

  Widget _priceCard(String price) {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          colors: [
            const Color(
              0xFFFF4DA6,
            ).withValues(
              alpha: 0.15,
            ),

            const Color(
              0xFF00D4FF,
            ).withValues(
              alpha: 0.08,
            ),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color: Colors.white
              .withValues(
            alpha: 0.08,
          ),
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.attach_money,
            color:
                Color(0xFFFF4DA6),
            size: 30,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  'PROPERTY VALUE',

                  style:
                      GoogleFonts
                          .poppins(
                    color:
                        Colors.white54,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                    letterSpacing:
                        1,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  price,

                  style:
                      GoogleFonts
                          .bebasNeue(
                    color:
                        const Color(
                      0xFFFF4DA6,
                    ),
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color:
              const Color(0xFF00D4FF),
          size: 21,
        ),

        const SizedBox(
          width: 8,
        ),

        Text(
          title,

          style:
              GoogleFonts.bebasNeue(
            color:
                const Color(
              0xFFFF4DA6,
            ),

            fontSize: 23,
            fontWeight:
                FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 9,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white
            .withValues(
          alpha: 0.045,
        ),

        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color:
                const Color(
              0xFF00D4FF,
            ),
            size: 21,
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Text(
              title,

              style:
                  GoogleFonts.poppins(
                color:
                    Colors.white60,
                fontSize: 12,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,

              textAlign:
                  TextAlign.right,

              style:
                  GoogleFonts.poppins(
                color:
                    Colors.white,
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuresCard(
    String features,
  ) {
    final featureList =
        features
            .split('•')
            .map(
              (e) => e.trim(),
            )
            .where(
              (e) =>
                  e.isNotEmpty,
            )
            .toList();

    if (featureList.isEmpty) {
      return _infoRow(
        Icons.info_outline,
        'Features',
        'No features available',
      );
    }

    return Container(
      padding:
          const EdgeInsets.all(15),

      decoration:
          BoxDecoration(
        color: Colors.white
            .withValues(
          alpha: 0.045,
        ),

        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child:
          Column(
        children:
            featureList
                .map(
          (feature) {
            return Padding(
              padding:
                  const EdgeInsets
                      .only(
                bottom: 11,
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color:
                        Color(
                      0xFF00D4FF,
                    ),
                    size: 19,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Text(
                      feature,

                      style:
                          GoogleFonts
                              .poppins(
                        color:
                            Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _ratingCard(
    Map<String, String> property,
  ) {
    final type =
        property['type'] ?? '';

    double luxury = 4.5;
    double location = 4.5;
    double privacy = 4.0;
    double entertainment = 4.0;

    if (type == 'Penthouse') {
      luxury = 5.0;
      location = 5.0;
      privacy = 4.8;
      entertainment = 5.0;
    } else if (type == 'Villa') {
      luxury = 4.8;
      location = 5.0;
      privacy = 4.5;
      entertainment = 4.8;
    } else if (type == 'Mansion') {
      luxury = 5.0;
      location = 4.5;
      privacy = 5.0;
      entertainment = 4.8;
    }

    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color: Colors.white
            .withValues(
          alpha: 0.045,
        ),

        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child:
          Column(
        children: [
          _ratingRow(
            'Luxury',
            luxury,
          ),

          _ratingRow(
            'Location',
            location,
          ),

          _ratingRow(
            'Privacy',
            privacy,
          ),

          _ratingRow(
            'Entertainment',
            entertainment,
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(
    String title,
    double rating,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 13,
      ),

      child: Row(
        children: [
          SizedBox(
            width: 105,

            child: Text(
              title,

              style:
                  GoogleFonts.poppins(
                color:
                    Colors.white60,
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            child:
                LinearProgressIndicator(
              value:
                  rating / 5,

              minHeight: 6,

              borderRadius:
                  BorderRadius.circular(
                10,
              ),

              backgroundColor:
                  Colors.white
                      .withValues(
                alpha: 0.08,
              ),

              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                Color(
                  0xFFFF4DA6,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Text(
            rating.toStringAsFixed(
              1,
            ),

            style:
                GoogleFonts.poppins(
              color:
                  Colors.white,
              fontSize: 12,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FULLSCREEN PROPERTY GALLERY
// ============================================================================

class _PropertyGalleryScreen
    extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String propertyName;

  const _PropertyGalleryScreen({
    required this.images,
    required this.initialIndex,
    required this.propertyName,
  });

  @override
  State<_PropertyGalleryScreen>
      createState() =>
          _PropertyGalleryScreenState();
}

class _PropertyGalleryScreenState
    extends State<_PropertyGalleryScreen> {
  late final PageController
      _controller;

  late int _current;

  @override
  void initState() {
    super.initState();

    _current =
        widget.initialIndex;

    _controller =
        PageController(
      initialPage:
          widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _image(String image) {
    if (image.startsWith(
          'http://',
        ) ||
        image.startsWith(
          'https://',
        )) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder:
            (_, __, ___) =>
                const Icon(
          Icons
              .broken_image_outlined,
          color:
              Colors.white38,
          size: 70,
        ),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder:
          (_, __, ___) =>
              const Icon(
        Icons
            .broken_image_outlined,
        color:
            Colors.white38,
        size: 70,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.black,

      appBar: AppBar(
        backgroundColor:
            Colors.black,

        foregroundColor:
            Colors.white,

        title: Text(
          widget.propertyName,

          style:
              GoogleFonts.bebasNeue(
            fontSize: 23,
            letterSpacing: 1,
          ),
        ),
      ),

      body: Stack(
        children: [
          PageView.builder(
            controller:
                _controller,

            itemCount:
                widget.images.length,

            onPageChanged:
                (index) {
              setState(() {
                _current =
                    index;
              });
            },

            itemBuilder:
                (_, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,

                child: Center(
                  child:
                      _image(
                    widget.images[
                        index],
                  ),
                ),
              );
            },
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 25,

            child: Center(
              child:
                  Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.black
                      .withValues(
                    alpha: 0.65,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),

                child: Text(
                  '${_current + 1} / ${widget.images.length}',

                  style:
                      GoogleFonts
                          .poppins(
                    color:
                        Colors.white,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
