class CleaningService {
  final String id;
  final String title;
  final String description;
  final double price;
  final int duration; // em minutos
  final List<String> images;
  final bool isAvailable;
  final String professionalId;
  final double rating;
  final int totalRatings;

  CleaningService({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.images,
    required this.isAvailable,
    required this.professionalId,
    this.rating = 0.0,
    this.totalRatings = 0,
  });

  factory CleaningService.fromJson(Map<String, dynamic> json) {
    return CleaningService(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as int,
      images: List<String>.from(json['images']),
      isAvailable: json['isAvailable'] as bool,
      professionalId: json['professionalId'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'duration': duration,
      'images': images,
      'isAvailable': isAvailable,
      'professionalId': professionalId,
      'rating': rating,
      'totalRatings': totalRatings,
    };
  }
} 