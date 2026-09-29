class PremiumCinematic {
  final String id;
  final String title;
  final String description;
  final String category;
  final String youtubeId;
  final String thumbnailUrl;
  final bool isActive;
  final bool isFeatured;
  final String orientation;

  const PremiumCinematic({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.youtubeId,
    required this.thumbnailUrl,
    required this.isActive,
    required this.isFeatured,
    required this.orientation,
  });

  bool get isVertical => orientation.toLowerCase() == 'vertical';

  double get aspectRatio => isVertical ? 9 / 16 : 16 / 9;

  factory PremiumCinematic.fromJson(Map<String, dynamic> json) {
    final orientation =
        json['orientation']?.toString().toLowerCase() ?? 'horizontal';

    return PremiumCinematic(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Cinematic',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Cinematic',
      youtubeId: json['youtubeId']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      isActive: json['isActive'] == true,
      isFeatured: json['isFeatured'] == true,
      orientation: orientation == 'vertical'
          ? 'vertical'
          : 'horizontal',
    );
  }
}