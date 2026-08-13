import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gta_6_comapnion_app/property_details_screen.dart';
import 'package:gta_6_comapnion_app/services/premium_screen.dart';
import 'package:gta_6_comapnion_app/services/premium_state.dart';

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

  String selectedCategory = 'All';
  @override
void initState() {
  super.initState();
  _loadFavorites();
}

Future<void> _loadFavorites() async {
  final prefs = await SharedPreferences.getInstance();

  final Set<String> savedFavorites = {};

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
  Set<String> favoriteProperties = {};
bool showFavorites = false;

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

  final List<Map<String, String>> properties = [
    {
      'name': "Brian's House",
    'type': 'Safe House',
    'location': 'Leonida',
    'price': 'Unknown',
    'status': 'Concept',
    'image': 'assets/images/brain_house.png',
    'description':
        "A luxurious private residence concept surrounded by tropical landscaping and premium vehicle parking. Designed as a high-end safehouse-style property.",
    'features':
        'Large Garage • Gated Entrance • Luxury Interior • Tropical Garden • Waterfront Views',
    'bedrooms': 'Unknown',
    'bathrooms': 'Unknown',
    'garage': 'Multiple Vehicles',
    'pool': 'Unknown',
    'security': 'High',
    'privacy': 'Very High',
    'bestFor': 'Luxury Safehouse',
  },
  {
  'name': 'Port Gellhorn Motel',
  'type': 'Safe House',
  'location': 'Port Gellhorn',
  'price': 'Unknown',
  'status': 'Reported',
  'image': 'assets/images/port_gellhorn_motel.png',
  'description':
      'A weathered coastal motel in Port Gellhorn presented as a reported safehouse location. The property features a two-story motel layout, roadside parking and a distinctly local coastal atmosphere.',
  'features':
      'Two-Story Motel • Roadside Parking • Multiple Rooms • Coastal Location • Safehouse Potential • Classic Motel Design',
  'bedrooms': 'Multiple Rooms',
  'bathrooms': 'Unknown',
  'garage': 'Outdoor Parking',
  'pool': 'Unknown',
  'security': 'Unknown',
  'privacy': 'Medium',
  'bestFor': 'Safehouse / Hideout',
},

{
  'name': 'Vice City Marina Residence',
  'type': 'Residence',
  'location': 'Vice City Marina',
  'price': 'Unknown',
  'status': 'Concept',
  'image': 'assets/images/vice_city_marina_residence.png',
  'description':
      'A modern waterfront residence concept overlooking the Vice City marina. The design combines luxury interiors, tropical landscaping, private vehicle access and direct waterfront surroundings.',
  'features':
      'Waterfront Location • Marina Views • Private Garage • Rooftop Terrace • Luxury Interior • Tropical Landscaping • Yacht Access',
  'bedrooms': 'Unknown',
  'bathrooms': 'Unknown',
  'garage': 'Private Garage',
  'pool': 'Yes',
  'security': 'High',
  'privacy': 'High',
  'bestFor': 'Waterfront Lifestyle',
},

{
  'name': 'Vice City Luxury Mansion',
  'type': 'Mansion',
  'location': 'Vice City',
  'price': 'Unknown',
  'status': 'Concept',
  'image': 'assets/images/vice_city_luxury_mansion.png',
  'description':
      'A large waterfront luxury mansion concept designed around tropical landscaping, premium entertainment areas and expansive Vice City views.',
  'features':
      'Waterfront Views • Large Swimming Pool • Multiple Garages • Grand Entrance • Tropical Gardens • Luxury Outdoor Area • Premium Interior',
  'bedrooms': 'Unknown',
  'bathrooms': 'Unknown',
  'garage': 'Multiple Vehicles',
  'pool': 'Large Pool',
  'security': 'Very High',
  'privacy': 'Very High',
  'bestFor': 'Luxury Living & Entertainment',
},

{
  'name': "Boobie's Property",
  'type': 'Property',
  'location': 'Leonida',
  'price': 'Unknown',
  'status': 'Observed',
  'image': 'assets/images/boobies_property.png',
  'description':
      "A distinctive waterfront property presented as observed in the available reference material. The residence features a colorful coastal design, dock access and a relaxed Vice City lifestyle aesthetic.",
  'features':
      'Waterfront Setting • Private Dock • Boat Access • Tropical Landscaping • Outdoor Parking • Coastal Architecture • Entertainment Area',
  'bedrooms': 'Unknown',
  'bathrooms': 'Unknown',
  'garage': 'Outdoor Parking',
  'pool': 'Waterfront Access',
  'security': 'Unknown',
  'privacy': 'Medium',
  'bestFor': 'Waterfront Recreation',
},

  {
    'name': 'Grassriverside Estate',
    'type': 'Mansion',
    'location': 'Leonida',
    'price': 'Unknown',
    'status': 'Concept',
    'image': 'assets/images/grassriverside_estate.png',
    'description':
        'A grand riverside estate concept surrounded by tropical vegetation, landscaped gardens and elegant architecture. Designed for an exclusive countryside lifestyle.',
    'features':
        'Riverside Location • Grand Entrance • Fountain • Large Garden • Luxury Interior • Private Driveway',
    'bedrooms': 'Unknown',
    'bathrooms': 'Unknown',
    'garage': 'Multiple Vehicles',
    'pool': 'Unknown',
    'security': 'High',
    'privacy': 'Very High',
    'bestFor': 'Luxury & Privacy',
  },

  {
    'name': 'Ocean Beach Residence',
    'type': 'Villa',
    'location': 'Ocean Beach, Vice City',
    'price': 'Unknown',
    'status': 'Concept',
    'image': 'assets/images/ocean_beach_residence.png',
    'description':
        'A modern oceanfront residence concept featuring tropical surroundings, direct beach views, luxury entertainment areas and a private gated entrance.',
    'features':
        'Ocean Views • Beach Access • Private Garage • Pool Area • Tropical Garden • Entertainment Terrace',
    'bedrooms': 'Unknown',
    'bathrooms': 'Unknown',
    'garage': 'Multiple Vehicles',
    'pool': 'Yes',
    'security': 'High',
    'privacy': 'High',
    'bestFor': 'Beach Lifestyle',
  },

  {
    'name': 'Catalan Boulevard Penthouse',
    'type': 'Penthouse',
    'location': 'Catalan Boulevard, Vice City',
    'price': 'Unknown',
    'status': 'Concept',
    'image': 'assets/images/penthouse.png',
    'description':
        'An ultra-luxury penthouse concept overlooking the Vice City skyline and ocean, featuring a rooftop entertainment area and premium city lifestyle.',
    'features':
        '360° Views • Rooftop Terrace • Infinity Pool • Private Bar • Spa • Luxury Interior • Firepit',
    'bedrooms': 'Unknown',
    'bathrooms': 'Unknown',
    'garage': 'Private Parking',
    'pool': 'Infinity Pool',
    'security': 'Very High',
    'privacy': 'Very High',
    'bestFor': 'Luxury City Lifestyle',},
    {
  
      'name': 'Luxury Mansion',
      'type': 'Mansion',
      'location': 'Vice City',
      'price': '\$2,500,000',
      'image': 'assets/images/beach_villa.png',
      'description':
          'Premium property concept for the GTA 6 Companion Pro database.',
      'features':
          'Garage • Security • Luxury Interior • Premium Location',
    },
    {
      'name': 'Modern Apartment',
      'type': 'Apartment',
      'location': 'Vice City',
      'price': '\$850,000',
      'image': 'assets/images/beach_villa.png',
      'description':
          'Modern apartment concept for the premium property database.',
      'features':
          'City View • Parking • Modern Interior • Central Location',
    },
    {
      'name': 'Beach Villa',
      'type': 'Villa',
      'location': 'Vice Beach',
      'price': '\$1,750,000',
      'image': 'assets/images/beach_villa.png',
      'description':
          'Beach-side property concept for the GTA 6 Companion.',
      'features':
          'Beach Access • Garage • Pool • Premium Location',
    },
    {
      'name': 'Safe House',
      'type': 'Safe House',
      'location': 'Vice City',
      'price': '\$650,000',
      'image': 'assets/images/beach_villa.png',
      'description':
          'Secure property concept designed for the Pro database.',
      'features':
          'Security • Storage • Garage • Safe Location',
    },
    {
      'name': 'Downtown Business',
      'type': 'Business',
      'location': 'Downtown',
      'price': '\$3,200,000',
      'description':
          'Commercial property concept for the premium database.',
      'features':
          'Office • Parking • Security • Central Location',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredProperties {
  final query = _searchController.text.toLowerCase().trim();

  return properties.where((property) {
    final name = property['name'] ?? '';
    final type = property['type'] ?? '';
    final location = property['location'] ?? '';

    final matchesFavorites =
        !showFavorites ||
        favoriteProperties.contains(name);

    final matchesCategory =
        selectedCategory == 'All' ||
        type == selectedCategory;

    final matchesSearch =
        query.isEmpty ||
        name.toLowerCase().contains(query) ||
        location.toLowerCase().contains(query) ||
        type.toLowerCase().contains(query);

    return matchesFavorites &&
        matchesCategory &&
        matchesSearch;
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    if (!premiumState.isPremium) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: _appBar(),
        body: _lockedScreen(context),
      );
    }

    final filtered = filteredProperties;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _appBar(),
      body: Column(
        children: [
          _searchBox(),

          _categorySelector(),
          Padding(
  padding: const EdgeInsets.fromLTRB(
    16,
    10,
    16,
    4,
  ),
  child: SizedBox(
    width: double.infinity,
    height: 46,
    child: OutlinedButton.icon(
      onPressed: () {
        setState(() {
          showFavorites = !showFavorites;
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
            : 'MY FAVORITES (${favoriteProperties.length})',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFF4DA6),
        side: const BorderSide(
          color: Color(0xFFFF4DA6),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  ),
),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                Text(
                  '${filtered.length} Properties',
                  style: GoogleFonts.poppins(
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
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      5,
                      16,
                      20,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _propertyCard(
                        context,
                        filtered[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      title: Row(
        children: [
          Text(
            'GTA 6 PROPERTIES',
            style: GoogleFonts.bebasNeue(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.workspace_premium,
            color: Colors.amber,
            size: 20,
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: TextField(
        controller: _searchController,
        
        onChanged: (_) {
          setState(() {});
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search properties...',
          hintStyle: const TextStyle(
            color: Colors.white38,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF00D4FF),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white54,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _categorySelector() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFF4DA6)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  color: selected
                      ? Colors.white
                      : Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _lockedScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              color: Colors.amber,
              size: 70,
            ),

            const SizedBox(height: 20),

            Text(
              'GTA 6 PRO FEATURE',
              style: GoogleFonts.bebasNeue(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: const Color(0xFFFF4DA6),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Unlock GTA 6 Pro to access the complete property database.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PremiumScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4DA6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'UNLOCK GTA 6 PRO',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _propertyCard(
    BuildContext context,
    Map<String, String> property,
  ) {
    return GestureDetector(
      onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PropertyDetailsScreen(
        property: property,
      ),
    ),
  );

  await _loadFavorites();
},
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
  borderRadius: const BorderRadius.vertical(
    top: Radius.circular(20),
  ),
  child: Image.asset(
  property['image'] ?? 'assets/images/beach_villa.png',
  height: 180,
  width: double.infinity,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFF1B1B1B),
      child: const Icon(
        Icons.home_work,
        color: Colors.white38,
        size: 60,
      ),
    );
  },
)
),

            Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
  children: [
    Expanded(
      child: Text(
        property['name'] ?? 'Unknown Property',
        style: GoogleFonts.bebasNeue(
          fontSize: 27,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),

    Icon(
      favoriteProperties.contains(
        property['name'],
      )
          ? Icons.favorite
          : Icons.favorite_border,
      color: favoriteProperties.contains(
        property['name'],
      )
          ? const Color(0xFFFF4DA6)
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
                        color: Color(0xFF00D4FF),
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        property['location'] ?? 'Unknown Location',
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property['price'] ?? 'Unknown',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 23,
                          color: const Color(0xFFFF4DA6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4FF)
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          property['type'] ?? 'Property',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF00D4FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
                        style: GoogleFonts.bebasNeue(
                          color: Colors.white70,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white70,
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

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            color: Colors.white30,
            size: 55,
          ),
          const SizedBox(height: 12),
          Text(
            'NO PROPERTIES FOUND',
            style: GoogleFonts.bebasNeue(
              color: Colors.white70,
              fontSize: 22,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Try another search or category.',
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}