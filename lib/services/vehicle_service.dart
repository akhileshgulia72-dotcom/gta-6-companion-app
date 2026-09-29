import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/vehicle_model.dart';

class VehicleService {
  static const String _vehiclesUrl =
      'https://raw.githubusercontent.com/akhileshgulia72-dotcom/gta6-news-server/refs/heads/main/vehicles.json';

  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await http.get(
        Uri.parse(_vehiclesUrl),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load vehicles: ${response.statusCode}',
        );
      }

      final List<dynamic> data = jsonDecode(response.body);

      final vehicles = data
          .map(
            (vehicle) => VehicleModel.fromJson(
              Map<String, dynamic>.from(vehicle),
            ),
          )
          .where((vehicle) => vehicle.isActive)
          .toList();

      return vehicles;
    } catch (e) {
      throw Exception(
        'Failed to load vehicles: $e',
      );
    }
  }
}