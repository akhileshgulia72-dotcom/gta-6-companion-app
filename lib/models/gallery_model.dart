class GalleryModel {
  final int id;
  final String imageUrl;

  GalleryModel({
    required this.id,
    required this.imageUrl,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
    );
  }
}