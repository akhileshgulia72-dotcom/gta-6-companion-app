import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/vehicle_model.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final VehicleModel vehicle;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Vehicle Details',
          style: GoogleFonts.bebasNeue(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // VEHICLE IMAGE
            // =====================================================

            _buildVehicleImage(),

            // =====================================================
            // MAIN INFORMATION
            // =====================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle name
                  Text(
                    vehicle.name,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Manufacturer
                  Text(
                    vehicle.manufacturer,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00D4FF),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Status + category
                  Row(
                    children: [
                      _buildBadge(
                        vehicle.status,
                        Icons.verified_outlined,
                      ),

                      const SizedBox(width: 10),

                      _buildBadge(
                        vehicle.category,
                        Icons.category_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // =================================================
                  // DESCRIPTION
                  // =================================================

                  _sectionTitle('DESCRIPTION'),

                  const SizedBox(height: 10),

                  Text(
                    vehicle.description.isEmpty
                        ? 'No description available.'
                        : vehicle.description,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // PERFORMANCE
                  // =================================================

                  _sectionTitle('PERFORMANCE'),

                  const SizedBox(height: 12),

                  _buildPerformanceGrid(),

                  const SizedBox(height: 30),

                  // =================================================
                  // VEHICLE INFORMATION
                  // =================================================

                  _sectionTitle('VEHICLE INFORMATION'),

                  const SizedBox(height: 12),

                  _buildInfoRow(
                    Icons.settings,
                    'Drivetrain',
                    vehicle.drivetrain,
                  ),

                  _buildInfoRow(
                    Icons.event_seat,
                    'Seating',
                    vehicle.seating,
                  ),

                  _buildInfoRow(
                    Icons.attach_money,
                    'Price',
                    vehicle.price,
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // FEATURES
                  // =================================================

                  _sectionTitle('FEATURES'),

                  const SizedBox(height: 12),

                  _buildFeatures(),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // VEHICLE IMAGE
  // ===============================================================

  Widget _buildVehicleImage() {
    if (vehicle.imageUrl.isEmpty) {
      return Container(
        height: 280,
        width: double.infinity,
        color: const Color(0xFF202020),
        child: const Icon(
          Icons.directions_car_filled,
          size: 100,
          color: Colors.white24,
        ),
      );
    }

    return Image.network(
      vehicle.imageUrl,
      height: 280,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Container(
          height: 280,
          width: double.infinity,
          color: const Color(0xFF202020),
          child: const Icon(
            Icons.directions_car_filled,
            size: 100,
            color: Colors.white24,
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
          height: 280,
          width: double.infinity,
          color: const Color(0xFF202020),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.bebasNeue(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: const Color(0xFFFF4DA6),
      ),
    );
  }

  // ===============================================================
  // BADGE
  // ===============================================================

  Widget _buildBadge(
    String text,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF00D4FF),
          ),

          const SizedBox(width: 6),

          Text(
            text.isEmpty ? 'Unknown' : text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PERFORMANCE GRID
  // ===============================================================

  Widget _buildPerformanceGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.1,
      children: [
        _performanceCard(
          Icons.speed,
          'TOP SPEED',
          vehicle.topSpeed,
        ),

        _performanceCard(
          Icons.flash_on,
          'ACCELERATION',
          vehicle.acceleration,
        ),

        _performanceCard(
          Icons.control_camera,
          'HANDLING',
          vehicle.handling,
        ),

        _performanceCard(
          Icons.stop_circle_outlined,
          'BRAKING',
          vehicle.braking,
        ),
      ],
    );
  }

  Widget _performanceCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF00D4FF),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value.isEmpty ? 'Unknown' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // INFORMATION ROW
  // ===============================================================

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    final displayValue =
        value.isEmpty ? 'Unknown' : value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF00D4FF),
            size: 20,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ),

          Text(
            displayValue,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FEATURES
  // ===============================================================

  Widget _buildFeatures() {
    if (vehicle.features.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'No features available.',
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: vehicle.features.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00D4FF)
                  .withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            feature,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}