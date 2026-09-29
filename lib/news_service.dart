import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gta_6_comapnion_app/news_model.dart';

class NewsService {
  static const String newsUrl =
      'https://raw.githubusercontent.com/akhileshgulia72-dotcom/gta6-news-server/main/news.json';

  Future<List<News>> fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse(newsUrl),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map(
              (item) => News.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load news: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('NEWS SERVICE ERROR: $e');
      rethrow;
    }
  }
}