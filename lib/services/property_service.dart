import 'dart:convert';

import 'package:http/http.dart' as http;

class PropertyService {
  static const String _propertiesUrl =
      'https://raw.githubusercontent.com/akhileshgulia72-dotcom/gta6-news-server/refs/heads/main/properties.json';

  Future<List<Map<String, dynamic>>> getProperties() async {
    try {
      final response = await http.get(
        Uri.parse(_propertiesUrl),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load properties: ${response.statusCode}',
        );
      }

      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .where(
            (property) =>
                property['is_active'] != false,
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to load properties: $e',
      );
    }
  }
}