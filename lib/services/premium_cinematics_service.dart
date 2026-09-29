import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/premium_cinematic_model.dart';

class PremiumCinematicsService {
  static const String cinematicsUrl =
      'https://raw.githubusercontent.com/akhileshgulia72-dotcom/gta6-news-server/main/premium_cinematics.json';

  Future<List<PremiumCinematic>> fetchCinematics() async {
    try {
      final response = await http
          .get(
            Uri.parse(cinematicsUrl),
            headers: {
              'Cache-Control': 'no-cache',
            },
          )
          .timeout(
            const Duration(seconds: 12),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'GitHub returned ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Invalid cinematics configuration.',
        );
      }

      final List<dynamic> videos =
          decoded['videos'] is List
              ? decoded['videos']
              : [];

      return videos
          .map(
            (item) => PremiumCinematic.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where(
            (video) =>
                video.isActive &&
                video.youtubeId.isNotEmpty,
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Unable to load Pro Cinematics: $e',
      );
    }
  }
}