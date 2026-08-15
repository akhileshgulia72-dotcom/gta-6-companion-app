import 'package:gta_6_comapnion_app/news_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<News>> fetchNews() async {
    try {
      final response = await _supabase
          .from('NEWS TABLE')
          .select()
          .order('published_at', ascending: false);

      return (response as List)
          .map(
            (item) => News.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (e) {
      print('NEWS SERVICE ERROR: $e');
      rethrow;
    }
  }
}