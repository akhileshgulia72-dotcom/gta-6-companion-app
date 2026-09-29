import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/august_event_model.dart';

class AugustEventService {
  static const String _url =
      'https://raw.githubusercontent.com/akhileshgulia72-dotcom/gta6-news-server/refs/heads/main/august_event.json';

  Future<AugustEventModel> getEvent() async {
    try {
      final response = await http.get(
        Uri.parse(_url),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body);

        return AugustEventModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to load event: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Unable to load August event: $e');
    }
  }
}