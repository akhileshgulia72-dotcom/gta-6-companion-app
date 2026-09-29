import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/gallery_model.dart';

class GalleryService {
  static const String _galleryUrl =
      'https://raw.githubusercontent.com/akhileshgulia72-dotcom/gta6-news-server/refs/heads/main/gallery.json';

  Future<List<GalleryModel>> getGalleryImages() async {
    try {
      final response = await http.get(
        Uri.parse(_galleryUrl),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load gallery: ${response.statusCode}',
        );
      }

      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map(
            (item) => GalleryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to load gallery images: $e',
      );
    }
  }
}