import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gta_6_comapnion_app/vehicle_details_screen.dart';

import 'models/vehicle_model.dart';
import 'services/vehicle_service.dart';
import 'services/premium_state.dart';

class PremiumVehiclesScreen extends StatefulWidget {
  const PremiumVehiclesScreen({super.key});

  @override
  State<PremiumVehiclesScreen> createState() => _PremiumVehiclesScreenState();
}

class _PremiumVehiclesScreenState extends State<PremiumVehiclesScreen> {
  final VehicleService _vehicleService = VehicleService();

  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;
  String? _error;

  String _selectedCategory = 'All';
  String _searchQuery = '';

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

  @override
  void initState() {
    super.initState();

    premiumState.addListener(_premiumChanged);

    _loadVehicles();
  }

  void _premiumChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    premiumState.removeListener(_premiumChanged);
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehicleService.getVehicles();

      if (!mounted) return;

      setState(() {
        _vehicles = vehicles;
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

  List<VehicleModel> get _filteredVehicles {
    return _vehicles.where((vehicle) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          vehicle.category.toLowerCase() == _selectedCategory.toLowerCase();

      final query = _searchQuery.toLowerCase().trim();

      final matchesSearch =
          query.isEmpty ||
          vehicle.name.toLowerCase().contains(query) ||
          vehicle.manufacturer.toLowerCase().contains(query) ||
          vehicle.category.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Premium protection
    if (!premiumState.isPremium) {
      return _buildLockedScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          'Vehicle Database',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildVehicleDatabase(),
    );
  }

  Widget _buildLockedScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          'Vehicle Database',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_rounded,
                size: 80,
                color: Color(0xFFFF4DA6),
              ),

              const SizedBox(height: 20),

              Text(
                'Premium Vehicle Database',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Unlock GTA 6 PRO to access the complete vehicle database.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4DA6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                child: Text(
                  'Unlock GTA 6 PRO',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDatabase() {
    return Column(
      children: [
        _buildSearchBar(),

        _buildCategories(),

        Expanded(child: _buildVehicleList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search vehicles...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load vehicles',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });

                  _loadVehicles();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final vehicles = _filteredVehicles;

    if (vehicles.isEmpty) {
      return Center(
        child: Text(
          'No vehicles found',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVehicles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          return _buildVehicleCard(vehicles[index]);
        },
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1C1C1C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicle.imageUrl.isNotEmpty)
              Image.network(
                vehicle.imageUrl,
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _vehicleImagePlaceholder();
                },
              )
            else
              _vehicleImagePlaceholder(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.name,
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _statusBadge(vehicle.status),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    vehicle.manufacturer,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF00D4FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _infoItem(Icons.category_outlined, vehicle.category),
                      const SizedBox(width: 18),
                      _infoItem(Icons.speed, vehicle.topSpeed),
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

  Widget _vehicleImagePlaceholder() {
    return Container(
      height: 190,
      width: double.infinity,
      color: const Color(0xFF252525),
      child: const Icon(
        Icons.directions_car_filled,
        size: 70,
        color: Colors.white24,
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF00D4FF)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
