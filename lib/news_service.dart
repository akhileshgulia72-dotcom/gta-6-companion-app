import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gta_6_comapnion_app/news_model.dart';

class NewsService {

  static const String newsUrl =
      "https://akhileshgulia72-dotcom.github.io/gta6-new/news.json";

  Future<List<News>> fetchNews() async {

    final response = await http.get(Uri.parse(newsUrl));

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final List articles = data["articles"];

      return articles
          .map((e) => News.fromJson(e))
          .where((e) => e.title != "[Removed]")
          .toList();

    } else {

      throw Exception("Failed to load news");

    }

  }

}