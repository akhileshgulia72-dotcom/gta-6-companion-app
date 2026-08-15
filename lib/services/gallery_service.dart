import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/gallery_model.dart';

class GalleryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<GalleryModel>> getGalleryImages() async {
    try {
      final response = await _supabase
          .from('gallery')
          .select('id, image_url')
          .order('id', ascending: true);

      return (response as List)
          .map(
            (image) => GalleryModel.fromJson(
              Map<String, dynamic>.from(image),
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