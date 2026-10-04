import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gta_6_comapnion_app/services/ad_manager.dart';

import 'package:gta_6_comapnion_app/vehicle_details_screen.dart';
import 'models/vehicle_model.dart';
import 'services/vehicle_service.dart';

import 'package:gta_6_comapnion_app/services/premium_state.dart';
class PremiumVehiclesScreen extends StatefulWidget {
  const PremiumVehiclesScreen({super.key});

  @override
  State<PremiumVehiclesScreen> createState() =>
      _PremiumVehiclesScreenState();
}

class _PremiumVehiclesScreenState
    extends State<PremiumVehiclesScreen> {
  final VehicleService _vehicleService = VehicleService();

  List<VehicleModel> _vehicles = [];

  bool _isLoading = true;
  String? _error;

  String _selectedCategory = 'All';
  String _searchQuery = '';

  // ============================================================
  // ADMOB CONFIGURATION
  // ============================================================

  // Native Ad Unit ID
  static String get _nativeAdUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-7694497723149363/3677097458'
          : 'ca-app-pub-7694497723149363/4612546853';
  // Native Ads
  final List<NativeAd?> _nativeAds = [];

  // Tracks which native ads are ACTUALLY loaded.
  final Set<int> _loadedNativeAdIndexes = {};
  // Click counter
  //
  // 1st click → open
  // 2nd click → open
  // 3rd click → open
  // 4th click → interstitial → open → reset
  int _vehicleClickCount = 0;

  final List<String> _categories = [
    'All',
    'Sports',
    'Super',
    'Muscle',
    'SUV',
    'Sedan',
    'Motorcycle',
    'Utility',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    premiumState.addListener(_onPremiumChanged);

    _loadVehicles();
    if (!premiumState.isPremium) {
      AdManager.preloadInterstitial();
    }
  }

  // ============================================================
  // LOAD VEHICLES
  // ============================================================

  Future<void> _loadVehicles() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final vehicles =
          await _vehicleService.getVehicles();

      if (!mounted) return;

      // Dispose old ads before creating new ones.
      _disposeNativeAds();

      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
        _error = null;
      });

      // Load native ads after vehicles are loaded.
      _prepareNativeAds();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // LOAD NATIVE ADS
  // ============================================================

  void _prepareNativeAds() {
    if (premiumState.isPremium) {
      _disposeNativeAds();
      return;
    }

    _disposeNativeAds();

    // Prepare only the first two native ad slots.
    // Additional slots are loaded when the user scrolls near them.
    final int adCount = _vehicles.length ~/ 3;
    final int initialCount = adCount.clamp(0, 2);

    for (int i = 0; i < initialCount; i++) {
      _loadNativeAd(i);
    }
  }

  void _loadNativeAd(int adIndex) {
    if (premiumState.isPremium) return;
    if (adIndex < 0) return;
    if (adIndex < _nativeAds.length && _nativeAds[adIndex] != null) {
      return;
    }

    while (_nativeAds.length <= adIndex) {
      _nativeAds.add(null);
    }

    final nativeAd = NativeAd(
      adUnitId: _nativeAdUnitId,
      factoryId: 'newsNativeAd',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted || premiumState.isPremium) {
            ad.dispose();
            return;
          }

          if (adIndex >= _nativeAds.length) {
            ad.dispose();
            return;
          }

          setState(() {
            _nativeAds[adIndex] = ad as NativeAd;
            _loadedNativeAdIndexes.add(adIndex);
          });

          debugPrint(
            'Vehicle native ad ${adIndex + 1} loaded successfully',
          );
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'Vehicle native ad ${adIndex + 1} failed: ${error.message}',
          );

          ad.dispose();

          if (!mounted) return;

          setState(() {
            if (adIndex < _nativeAds.length) {
              _nativeAds[adIndex] = null;
            }
            _loadedNativeAdIndexes.remove(adIndex);
          });
        },
      ),
    );

    _nativeAds[adIndex] = nativeAd;
    nativeAd.load();
  }

  void _ensureNativeAdsAround(int adIndex) {
    if (premiumState.isPremium) return;

    // Load the requested slot and one slot ahead.
    _loadNativeAd(adIndex);

    final int nextIndex = adIndex + 1;
    final int maxAdCount = _vehicles.length ~/ 3;

    if (nextIndex < maxAdCount) {
      _loadNativeAd(nextIndex);
    }
  }

  // ============================================================
  // BUILD NATIVE AD
  // ============================================================

  Widget _buildNativeAd(int adIndex) {
    // Safety check.
    if (adIndex < 0 ||
        adIndex >= _nativeAds.length) {
      return const SizedBox.shrink();
    }

    // IMPORTANT:
    // Do not show AdWidget until the ad has loaded.
    if (!_loadedNativeAdIndexes.contains(
      adIndex,
    )) {
      return const SizedBox.shrink();
    }

    final NativeAd? ad =
        _nativeAds[adIndex];

    if (ad == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(18),
        child: SizedBox(
          width: double.infinity,

          // Your Android native ad layout
          // will be displayed inside this area.
          height: 300,

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
    for (final ad in _nativeAds) {
      ad?.dispose();
    }

    _nativeAds.clear();
    _loadedNativeAdIndexes.clear();
  }

  // ============================================================
  // PREMIUM / INTERSTITIAL
  // ============================================================

  void _onPremiumChanged() {
    if (!premiumState.isPremium) return;

    _disposeNativeAds();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // VEHICLE CLICK LOGIC
  // ============================================================

  void _handleVehicleClick(
    VehicleModel vehicle,
  ) {
    if (premiumState.isPremium) {
      _openVehicle(vehicle);
      return;
    }

    _vehicleClickCount++;

    // Clicks 1-3 open normally.
    if (_vehicleClickCount < 4) {
      _openVehicle(vehicle);
      return;
    }

    // Click 4 attempts one centralized interstitial.
    _vehicleClickCount = 0;

    AdManager.showInterstitial(
      onFinished: () {
        _openVehicle(vehicle);
      },
    );
  }

  // ============================================================
  // OPEN VEHICLE DETAILS
  // ============================================================

  Future<void> _openVehicle(
    VehicleModel vehicle,
  ) async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            VehicleDetailsScreen(
          vehicle: vehicle,
        ),
      ),
    );
  }

  // ============================================================
  // FILTER VEHICLES
  // ============================================================

  List<VehicleModel> get _filteredVehicles {
    return _vehicles.where((vehicle) {
      final matchesCategory =
          _selectedCategory == 'All' ||
              vehicle.category.toLowerCase() ==
                  _selectedCategory.toLowerCase();

      final query =
          _searchQuery.toLowerCase().trim();

      final matchesSearch =
          query.isEmpty ||
              vehicle.name
                  .toLowerCase()
                  .contains(query) ||
              vehicle.manufacturer
                  .toLowerCase()
                  .contains(query) ||
              vehicle.category
                  .toLowerCase()
                  .contains(query);

      return matchesCategory &&
          matchesSearch;
    }).toList();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _disposeNativeAds();

    premiumState.removeListener(_onPremiumChanged);
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF121212),

        elevation: 0,

        title: Text(
          'Vehicle Database',
          style: GoogleFonts.poppins(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: _buildVehicleDatabase(),
    );
  }

  // ============================================================
  // VEHICLE DATABASE
  // ============================================================

  Widget _buildVehicleDatabase() {
    return Column(
      children: [
        _buildSearchBar(),

        _buildCategories(),

        Expanded(
          child: _buildVehicleList(),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),

      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },

        decoration: InputDecoration(
          hintText:
              'Search vehicles...',

          prefixIcon:
              const Icon(
            Icons.search,
          ),

          filled: true,

          fillColor:
              const Color(
            0xFF1E1E1E,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),

            borderSide:
                BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    return SizedBox(
      height: 50,

      child: ListView.builder(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
        ),

        scrollDirection:
            Axis.horizontal,

        itemCount:
            _categories.length,

        itemBuilder:
            (context, index) {
          final category =
              _categories[index];

          final selected =
              category ==
                  _selectedCategory;

          return Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 6,
            ),

            child: ChoiceChip(
              label:
                  Text(category),

              selected:
                  selected,

              onSelected: (_) {
                setState(() {
                  _selectedCategory =
                      category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // VEHICLE LIST
  //
  // VEHICLE 1
  // VEHICLE 2
  // VEHICLE 3
  //
  // NATIVE AD
  //
  // VEHICLE 4
  // VEHICLE 5
  // VEHICLE 6
  //
  // NATIVE AD
  // ============================================================

  Widget _buildVehicleList() {
    if (_isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
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
                Icons.error_outline,
                size: 60,
                color:
                    Colors.redAccent,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                'Unable to load vehicles',

                style:
                    GoogleFonts.poppins(
                  fontSize: 18,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                _error!,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color:
                      Colors.white60,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              ElevatedButton(
                onPressed: () {
                  _loadVehicles();
                },

                child:
                    const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final vehicles =
        _filteredVehicles;

    if (vehicles.isEmpty) {
      return Center(
        child: Text(
          'No vehicles found',

          style:
              GoogleFonts.poppins(
            color:
                Colors.white70,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVehicles,

      child: ListView.builder(
        padding:
            const EdgeInsets.all(16),

        // Add one ad slot after every 3 vehicles.
        itemCount:
            vehicles.length +
                (vehicles.length ~/ 3),

        itemBuilder:
            (context, index) {
          // Positions:
          //
          // 0 Vehicle
          // 1 Vehicle
          // 2 Vehicle
          // 3 Ad
          //
          // 4 Vehicle
          // 5 Vehicle
          // 6 Vehicle
          // 7 Ad

          if ((index + 1) % 4 == 0) {
            final adIndex =
                index ~/ 4;

            _ensureNativeAdsAround(adIndex);

            return _buildNativeAd(
              adIndex,
            );
          }

          // Convert displayed index
          // to actual vehicle index.
          final vehicleIndex =
              index -
                  ((index + 1) ~/ 4);

          if (vehicleIndex < 0 ||
              vehicleIndex >=
                  vehicles.length) {
            return const SizedBox.shrink();
          }

          return _buildVehicleCard(
            vehicles[vehicleIndex],
          );
        },
      ),
    );
  }

  // ============================================================
  // VEHICLE CARD
  // ============================================================

  Widget _buildVehicleCard(
    VehicleModel vehicle,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      color:
          const Color(
        0xFF1C1C1C,
      ),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      clipBehavior:
          Clip.antiAlias,

      child: InkWell(
        onTap: () {
          _handleVehicleClick(
            vehicle,
          );
        },

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            if (vehicle
                .imageUrl.isNotEmpty)
              Image.network(
                vehicle.imageUrl,

                height: 190,

                width:
                    double.infinity,

                fit: BoxFit.cover,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _vehicleImagePlaceholder();
                },
              )
            else
              _vehicleImagePlaceholder(),

            Padding(
              padding:
                  const EdgeInsets.all(
                16,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.name,

                          style:
                              GoogleFonts
                                  .poppins(
                            fontSize: 19,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                      _statusBadge(
                        vehicle.status,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    vehicle.manufacturer,

                    style:
                        GoogleFonts
                            .poppins(
                      color:
                          const Color(
                        0xFF00D4FF,
                      ),

                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: [
                      _infoItem(
                        Icons
                            .category_outlined,
                        vehicle.category,
                      ),

                      const SizedBox(
                        width: 18,
                      ),

                      _infoItem(
                        Icons.speed,
                        vehicle.topSpeed,
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
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _vehicleImagePlaceholder() {
    return Container(
      height: 190,

      width:
          double.infinity,

      color:
          const Color(
        0xFF252525,
      ),

      child: const Icon(
        Icons.directions_car_filled,

        size: 70,

        color:
            Colors.white24,
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
    String status,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white
                .withValues(alpha: 
          0.08,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Text(
        status,

        style:
            GoogleFonts.poppins(
          fontSize: 10,

          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        Icon(
          icon,

          size: 16,

          color:
              const Color(
            0xFF00D4FF,
          ),
        ),

        const SizedBox(
          width: 5,
        ),

        Text(
          text,

          style:
              const TextStyle(
            color:
                Colors.white70,

            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
