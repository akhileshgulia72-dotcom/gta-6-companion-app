class VehicleModel {
  final String id;
  final String name;
  final String manufacturer;
  final String category;
  final String status;
  final String imageUrl;
  final String description;

  final String topSpeed;
  final String acceleration;
  final String handling;
  final String braking;

  final String drivetrain;
  final String seating;
  final String price;

  final List<String> features;

  final bool isPremium;
  final bool isActive;

  VehicleModel({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.category,
    required this.status,
    required this.imageUrl,
    required this.description,
    required this.topSpeed,
    required this.acceleration,
    required this.handling,
    required this.braking,
    required this.drivetrain,
    required this.seating,
    required this.price,
    required this.features,
    required this.isPremium,
    required this.isActive,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      manufacturer: json['manufacturer']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',

      topSpeed: json['top_speed']?.toString() ?? 'Unknown',
      acceleration: json['acceleration']?.toString() ?? 'Unknown',
      handling: json['handling']?.toString() ?? 'Unknown',
      braking: json['braking']?.toString() ?? 'Unknown',

      drivetrain: json['drivetrain']?.toString() ?? 'Unknown',
      seating: json['seating']?.toString() ?? 'Unknown',
      price: json['price']?.toString() ?? 'Unknown',

      features: List<String>.from(
        json['features'] ?? const [],
      ),

      isPremium: json['is_premium'] ?? true,
      isActive: json['is_active'] ?? true,
    );
  }
}