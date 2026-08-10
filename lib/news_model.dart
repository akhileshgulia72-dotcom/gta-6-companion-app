class News {
  final String title;
  final String description;
  final String image;
  final String url;
  final String source;
  final String publishedAt;

  News({
    required this.title,
    required this.description,
    required this.image,
    required this.url,
    required this.source,
    required this.publishedAt,
  });
  

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json["title"] ?? "No Title",
      description: json["description"] ?? "No Description",
      image: json["urlToImage"] ??
          "https://via.placeholder.com/400x200?text=No+Image",
      url: json["url"] ?? "",
      source: json["source"]?["name"] ?? "Unknown",
      publishedAt: json["publishedAt"] ?? "",
    );
  }
}