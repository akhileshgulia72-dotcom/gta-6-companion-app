import 'package:flutter/material.dart';
import 'package:gta_6_comapnion_app/property_details_screen.dart';

class AdvancedMapScreen extends StatefulWidget {
  final String? focusProperty;

  const AdvancedMapScreen({
    super.key,
    this.focusProperty,
  });

  @override
  State<AdvancedMapScreen> createState() => _AdvancedMapScreenState();
}

class _AdvancedMapScreenState extends State<AdvancedMapScreen> {
  final TransformationController _controller = TransformationController();

  // =========================================================
  // PROPERTY MARKERS + COMPLETE PROPERTY DETAILS
  // =========================================================

  final List<MapMarker> markers = const [

    // ---------------------------------------------------------
    // 1. GRASSRIVERSIDE ESTATE
    // ---------------------------------------------------------

    MapMarker(
      name: "Grassriverside Estate",
      type: "Mansion",
      x: 0.61,
      y: 0.27,
      icon: Icons.home_work,
      color: Color(0xFFFF4DA6),

      location: "Grassrivers, Leonida",
      price: "\$2,850,000",

      image: "assets/images/grassriverside_estate.png",

      bedrooms: "6",
      bathrooms: "7",
      garage: "4-Car Garage",
      pool: "Private Infinity Pool",
      security: "24/7 Security",
      privacy: "Very High",
      bestFor: "Luxury Living & Entertainment",

      description:
          "A grand riverside estate surrounded by tropical landscaping "
          "and peaceful waterfront views.",

      features: [
        "Riverside Location",
        "Luxury Interior",
        "Private Garden",
        "Large Garage",
        "Waterfront Views",
      ],
    ),

    // ---------------------------------------------------------
    // 2. PORT GELLHORN MOTEL
    // ---------------------------------------------------------

    MapMarker(
      name: "Port Gellhorn Motel",
      type: "Safe House",
      x: 0.59,
      y: 0.39,
      icon: Icons.hotel,
      color: Color(0xFF00D4FF),

      location: "Port Gellhorn",
      price: "\$420,000",

      image: "assets/images/port_gellhorn_motel.png",

      bedrooms: "8 Rooms",
      bathrooms: "8",
      garage: "Parking Area",
      pool: "No Private Pool",
      security: "Basic Security",
      privacy: "Medium",
      bestFor: "Safehouse & Base Operations",

      description:
          "A compact coastal motel property that can serve as a "
          "practical safehouse and base of operations.",

      features: [
        "Safe House",
        "Parking Area",
        "Coastal Location",
        "Multiple Rooms",
        "Easy Road Access",
      ],
    ),

    // ---------------------------------------------------------
    // 3. CATALAN BOULEVARD PENTHOUSE
    // ---------------------------------------------------------

    MapMarker(
      name: "Catalan Boulevard Penthouse",
      type: "Penthouse",
      x: 0.73,
      y: 0.44,
      icon: Icons.apartment,
      color: Color(0xFFFF4DA6),

      location: "Catalan Boulevard, Vice City",
      price: "\$4,750,000",

      image: "assets/images/catalan_boulevard_penthouse.png",

      bedrooms: "4",
      bathrooms: "5",
      garage: "3-Car Private Garage",
      pool: "Infinity Pool",
      security: "Premium 24/7 Security",
      privacy: "High",
      bestFor: "Luxury City Living",

      description:
          "A high-end penthouse overlooking the Vice City skyline "
          "with premium entertainment and rooftop spaces.",

      features: [
        "360° City Views",
        "Private Rooftop",
        "Infinity Pool",
        "Luxury Interiors",
        "Private Lounge",
      ],
    ),

    // ---------------------------------------------------------
    // 4. BRIAN'S HOUSE
    // ---------------------------------------------------------

    MapMarker(
      name: "Brian's House",
      type: "Safe House",
      x: 0.77,
      y: 0.53,
      icon: Icons.home,
      color: Color(0xFFFF4DA6),

      location: "Vice City",
      price: "\$650,000",

      image: "assets/images/brians_house.png",

      bedrooms: "3",
      bathrooms: "2",
      garage: "2-Car Garage",
      pool: "Private Pool",
      security: "Private Security",
      privacy: "High",
      bestFor: "Comfortable Safehouse",

      description:
          "A stylish coastal safe house with private outdoor space, "
          "secure parking and a premium Vice City atmosphere.",

      features: [
        "Private Garage",
        "Swimming Pool",
        "Ocean View",
        "Secure Location",
        "Luxury Interior",
      ],
    ),

    // ---------------------------------------------------------
    // 5. VICE CITY LUXURY MANSION
    // ---------------------------------------------------------

    MapMarker(
      name: "Vice City Luxury Mansion",
      type: "Mansion",
      x: 0.72,
      y: 0.61,
      icon: Icons.domain,
      color: Color(0xFFFF4DA6),

      location: "Vice City",
      price: "\$5,900,000",

      image: "assets/images/vice_city_luxury_mansion.png",

      bedrooms: "8",
      bathrooms: "10",
      garage: "8-Car Garage",
      pool: "Large Infinity Pool",
      security: "Elite 24/7 Security",
      privacy: "Very High",
      bestFor: "Luxury & Entertainment",

      description:
          "An expansive luxury mansion designed around waterfront "
          "living, entertainment and premium vehicle storage.",

      features: [
        "Waterfront Location",
        "Large Swimming Pool",
        "Multiple Garages",
        "Luxury Bedrooms",
        "Entertainment Area",
      ],
    ),

    // ---------------------------------------------------------
    // 6. BOOBIE'S PROPERTY
    // ---------------------------------------------------------

    MapMarker(
      name: "Boobie's Property",
      type: "Property",
      x: 0.67,
      y: 0.55,
      icon: Icons.home,
      color: Color(0xFFFF4DA6),

      location: "Vice City",
      price: "\$1,250,000",

      image: "assets/images/boobies_property.png",

      bedrooms: "4",
      bathrooms: "3",
      garage: "2-Car Parking",
      pool: "Outdoor Pool",
      security: "Private Security",
      privacy: "Medium",
      bestFor: "Waterfront Living",

      description:
          "A colorful waterfront property with a relaxed Vice City "
          "atmosphere and access to the surrounding marina area.",

      features: [
        "Waterfront Access",
        "Private Dock",
        "Outdoor Area",
        "Parking",
        "Vice City Location",
      ],
    ),

    // ---------------------------------------------------------
    // 7. VICE CITY MARINA RESIDENCE
    // ---------------------------------------------------------

    MapMarker(
      name: "Vice City Marina Residence",
      type: "Residence",
      x: 0.66,
      y: 0.70,
      icon: Icons.house,
      color: Color(0xFFFF4DA6),

      location: "Vice City Marina",
      price: "\$2,100,000",

      image: "assets/images/vice_city_marina_residence.png",

      bedrooms: "5",
      bathrooms: "5",
      garage: "3-Car Garage",
      pool: "Private Pool",
      security: "24/7 Marina Security",
      privacy: "High",
      bestFor: "Marina & Waterfront Lifestyle",

      description:
          "A modern waterfront residence positioned beside the marina "
          "with premium views and easy boat access.",

      features: [
        "Marina Access",
        "Private Dock",
        "Waterfront Views",
        "Modern Interior",
        "Secure Parking",
      ],
    ),

    // ---------------------------------------------------------
    // 8. OCEAN BEACH RESIDENCE
    // ---------------------------------------------------------

    MapMarker(
      name: "Ocean Beach Residence",
      type: "Villa",
      x: 0.86,
      y: 0.56,
      icon: Icons.villa,
      color: Color(0xFFFF4DA6),

      location: "Ocean Beach, Vice City",
      price: "\$3,450,000",

      image: "assets/images/ocean_beach_residence.png",

      bedrooms: "5",
      bathrooms: "6",
      garage: "4-Car Garage",
      pool: "Private Beach Pool",
      security: "24/7 Security",
      privacy: "Very High",
      bestFor: "Beachfront Luxury Living",

      description:
          "A bright beachfront residence featuring tropical gardens, "
          "private outdoor spaces and direct ocean views.",

      features: [
        "Beachfront Location",
        "Private Pool",
        "Ocean View",
        "Tropical Garden",
        "Luxury Garage",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.focusProperty != null) {
        final marker = markers.cast<MapMarker?>().firstWhere(
          (m) => m!.name == widget.focusProperty,
          orElse: () => null,
        );

        if (marker != null && mounted) {
          _showMarkerDetails(marker);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final current = _controller.value.clone();
    current.scale(1.35);
    _controller.value = current;
  }

  void _zoomOut() {
    final current = _controller.value.clone();
    current.scale(0.74);
    _controller.value = current;
  }

  void _resetMap() {
    _controller.value = Matrix4.identity();
  }

  // =========================================================
  // SEND COMPLETE MARKER DATA TO PROPERTY DETAILS SCREEN
  // =========================================================

  Map<String, String> _propertyFromMarker(MapMarker marker) {
    return {
      'name': marker.name,
      'type': marker.type,
      'location': marker.location,
      'price': marker.price,
      'description': marker.description,
      'features': marker.features.join(' • '),

      'image': marker.image,
      'bedrooms': marker.bedrooms,
      'bathrooms': marker.bathrooms,
      'garage': marker.garage,
      'pool': marker.pool,
      'security': marker.security,
      'privacy': marker.privacy,
      'bestFor': marker.bestFor,
    };
  }

  void _showMarkerDetails(MapMarker marker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: marker.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: marker.color,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        marker.icon,
                        color: marker.color,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            marker.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            marker.type.toUpperCase(),
                            style: TextStyle(
                              color: marker.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF00D4FF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        marker.location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Text(
                  marker.price,
                  style: const TextStyle(
                    color: Color(0xFFFF4DA6),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  marker.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'FEATURES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: marker.features.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white12,
                        ),
                      ),
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PropertyDetailsScreen(
                            property: _propertyFromMarker(marker),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      'VIEW PROPERTY',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4DA6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _markerWidget(MapMarker marker) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: marker.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: marker.color.withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        marker.icon,
        color: Colors.white,
        size: 23,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final mapWidth = screenWidth;
    final mapHeight = screenWidth * 2;

    return Scaffold(
      backgroundColor: const Color(0xFF02050B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF070A14),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'LEONIDA MAP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.my_location,
              color: Color(0xFF00D4FF),
              size: 30,
            ),
            onPressed: _resetMap,
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 0.5,
              maxScale: 6.0,
              panEnabled: true,
              scaleEnabled: true,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(500),

              child: SizedBox(
                width: mapWidth,
                height: mapHeight,

                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/leonida_map.png',
                        fit: BoxFit.fill,
                      ),
                    ),

                    ...markers.map((marker) {
                      return Positioned(
                        left: marker.x * mapWidth - 21,
                        top: marker.y * mapHeight - 21,

                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _showMarkerDetails(marker);
                          },
                          child: _markerWidget(marker),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00D4FF),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.map,
                      color: Color(0xFF00D4FF),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'EXPLORE LEONIDA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      'DRAG TO MOVE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 15,
            bottom: 25,
            child: Column(
              children: [
                _mapButton(
                  icon: Icons.add,
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 12),
                _mapButton(
                  icon: Icons.remove,
                  onPressed: _zoomOut,
                ),
                const SizedBox(height: 12),
                _mapButton(
                  icon: Icons.layers,
                  onPressed: _showLayers,
                ),
                const SizedBox(height: 12),
                _mapButton(
                  icon: Icons.center_focus_strong,
                  onPressed: _resetMap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF4DA6),
          width: 1.2,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showLayers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'MAP LAYERS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _layerOption(
                  Icons.home,
                  'Properties',
                  const Color(0xFFFF4DA6),
                ),

                _layerOption(
                  Icons.local_gas_station,
                  'Vehicle Locations',
                  const Color(0xFF00D4FF),
                ),

                _layerOption(
                  Icons.flag,
                  'Missions',
                  Colors.orange,
                ),

                _layerOption(
                  Icons.local_hospital,
                  'Hospitals',
                  Colors.redAccent,
                ),

                _layerOption(
                  Icons.local_police,
                  'Police Stations',
                  Colors.blue,
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _layerOption(
    IconData icon,
    String title,
    Color color,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      trailing: Switch(
        value: true,
        onChanged: (_) {},
        activeThumbColor: color,
      ),
    );
  }
}

// =========================================================
// MAP MARKER MODEL
// =========================================================

class MapMarker {
  final String name;
  final String type;
  final double x;
  final double y;
  final IconData icon;
  final Color color;
  final String location;
  final String description;
  final String price;
  final List<String> features;

  // PROPERTY DETAILS
  final String image;
  final String bedrooms;
  final String bathrooms;
  final String garage;
  final String pool;
  final String security;
  final String privacy;
  final String bestFor;

  const MapMarker({
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    required this.icon,
    required this.color,
    required this.location,
    required this.description,
    required this.price,
    required this.features,

    required this.image,
    required this.bedrooms,
    required this.bathrooms,
    required this.garage,
    required this.pool,
    required this.security,
    required this.privacy,
    required this.bestFor,
  });
}