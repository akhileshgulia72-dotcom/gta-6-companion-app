class News {
  final int id;
  final DateTime createdAt;
  final String title;
  final String description;
  final String? imageUrl;
  final String source;
  final String articleContent;
  final String category;
  final DateTime publishedAt;
  final bool isFeatured;

  News({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.source,
    required this.articleContent,
    required this.category,
    required this.publishedAt,
    required this.isFeatured,
  });

  // Keeps compatibility with your existing HomeScreen:
  // news.image
  String get image => imageUrl ?? '';

  factory News.fromMap(Map<String, dynamic> map) {
    return News(
      id: map['id'] is int
          ? map['id'] as int
          : int.parse(map['id'].toString()),

      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),

      title: map['title']?.toString() ?? '',

      description: map['description']?.toString() ?? '',

      imageUrl: map['image_url']?.toString(),

      source: map['source']?.toString() ?? '',

      articleContent: map['article_content']?.toString() ?? '',

      category: map['category']?.toString() ?? 'News',

      publishedAt: map['published_at'] != null
          ? DateTime.parse(map['published_at'].toString())
          : DateTime.now(),

      isFeatured: map['is_featured'] == true,
    );
  }
}