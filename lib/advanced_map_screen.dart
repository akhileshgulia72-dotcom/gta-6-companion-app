import 'package:flutter/material.dart';

class AdvancedMapScreen extends StatefulWidget {
  const AdvancedMapScreen({super.key});

  @override
  State<AdvancedMapScreen> createState() => _AdvancedMapScreenState();
}

class _AdvancedMapScreenState extends State<AdvancedMapScreen> {

  void _showMarkerDetails(MapMarker marker) {
  showModalBottomSheet(
    context: context,

    backgroundColor: const Color(0xFF121212),

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25),
      ),
    ),

    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              Container(
                width: 45,
                height: 5,

                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 22),

              Container(
                width: 65,
                height: 65,

                decoration: BoxDecoration(
                  color: marker.color.withValues(
                    alpha: 0.15,
                  ),

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: marker.color,
                  ),
                ),

                child: Icon(
                  marker.icon,
                  color: marker.color,
                  size: 32,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                marker.name,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                marker.type,
                style: TextStyle(
                  color: marker.color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_forward,
                  ),

                  label: const Text(
                    "VIEW DETAILS",
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF4DA6),

                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
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

  final List<MapMarker> markers = const [
  MapMarker(
    name: "Grassriverside Estate",
    type: "Mansion",
    x: 0.61,
    y: 0.27,
    icon: Icons.home_work,
    color: Color(0xFFFF4DA6),
  ),

  MapMarker(
    name: "Port Gellhorn Motel",
    type: "Safe House",
    x: 0.59,
    y: 0.39,
    icon: Icons.hotel,
    color: Color(0xFF00D4FF),
  ),

  MapMarker(
    name: "Catalan Boulevard Penthouse",
    type: "Penthouse",
    x: 0.73,
    y: 0.44,
    icon: Icons.apartment,
    color: Color(0xFFFF4DA6),
  ),

  MapMarker(
    name: "Brian's House",
    type: "Safe House",
    x: 0.77,
    y: 0.53,
    icon: Icons.home,
    color: Color(0xFFFF4DA6),
  ),

  MapMarker(
    name: "Vice City Luxury Mansion",
    type: "Mansion",
    x: 0.72,
    y: 0.61,
    icon: Icons.domain,
    color: Color(0xFFFF4DA6),
  ),

  MapMarker(
    name: "Boobie's Property",
    type: "Property",
    x: 0.67,
    y: 0.55,
    icon: Icons.home,
    color: Color(0xFFFF4DA6),
  ),

  MapMarker(
    name: "Vice City Marina Residence",
    type: "Residence",
    x: 0.66,
    y: 0.70,
    icon: Icons.house,
    color: Color(0xFFFF4DA6),
  ),

  MapMarker(
    name: "Ocean Beach Residence",
    type: "Villa",
    x: 0.86,
    y: 0.56,
    icon: Icons.villa,
    color: Color(0xFFFF4DA6),
  ),
];
  
  final TransformationController _controller =
      TransformationController();

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

  @override
  Widget build(BuildContext context) {
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

          // =========================
          // FULL MAP
          // =========================
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _controller,

              minScale: 0.5,
              maxScale: 6.0,

              panEnabled: true,
              scaleEnabled: true,

              boundaryMargin:
                  const EdgeInsets.all(1000),

              child: Center(
                child: SizedBox(
  width: MediaQuery.of(context).size.width,
  child: AspectRatio(
    aspectRatio: 0.5,

    child: Stack(
      children: [

        Positioned.fill(
          child: Image.asset(
            'assets/images/leonida_map.png',
            fit: BoxFit.fill,
          ),
        ),

        ...markers.map(
          (marker) {
            return Positioned(
  left: marker.x *
          MediaQuery.of(context).size.width -
      21,

  top: marker.y *
          MediaQuery.of(context).size.width *
          2 -
      21,

  child: GestureDetector(
    onTap: () {
      _showMarkerDetails(marker);
    },

    child: _markerWidget(marker),
  ),
);
          },
        ),
      ],
    ),
  ),
)
              ),
            ),
          ),

          // =========================
          // TOP INFORMATION CARD
          // =========================
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.78,
                ),

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: const Color(0xFF00D4FF),
                  width: 1.2,
                ),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4FF)
                        .withValues(alpha: 0.15),
                    blurRadius: 15,
                  ),
                ],
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
                    'PINCH TO ZOOM',
                    style: TextStyle(
                      color: Colors.white
                          .withValues(alpha: 0.65),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // MAP CONTROLS
          // =========================
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
                  onPressed: () {
                    _showLayers();
                  },
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

  // =========================
  // MAP BUTTON
  // =========================
  Widget _mapButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 55,
      height: 55,

      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.82,
        ),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFFF4DA6),
          width: 1.2,
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4DA6)
                .withValues(alpha: 0.18),
            blurRadius: 12,
          ),
        ],
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

  // =========================
  // LAYERS
  // =========================
  void _showLayers() {
    showModalBottomSheet(
      context: context,

      backgroundColor:
          const Color(0xFF121212),

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
                    borderRadius:
                        BorderRadius.circular(10),
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
class MapMarker {
  final String name;
  final String type;
  final double x;
  final double y;
  final IconData icon;
  final Color color;

  const MapMarker({
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    required this.icon,
    required this.color,
  });
}