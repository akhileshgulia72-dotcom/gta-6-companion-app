import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/vehicle_model.dart';

class VehicleService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map(
            (vehicle) => VehicleModel.fromJson(
              Map<String, dynamic>.from(vehicle),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to load vehicles: $e',
      );
    }
  }

  // TEMPORARY TEST ONLY
  Future<void> testVehicleConnection() async {
    try {
      final vehicles = await getVehicles();

      print('====================================');
      print('🚗 VEHICLE DATABASE TEST');
      print('Vehicles found: ${vehicles.length}');

      for (final vehicle in vehicles) {
        print(
          'Vehicle: ${vehicle.name} | '
          'Category: ${vehicle.category} | '
          'Premium: ${vehicle.isPremium}',
        );
      }

      print('====================================');
    } catch (e) {
      print('❌ Vehicle database error: $e');
    }
  }
}