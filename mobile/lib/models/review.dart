import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String appointmentId;
  final String userId;
  final String professionalId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.appointmentId,
    required this.userId,
    required this.professionalId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      appointmentId: data['appointmentId'] ?? '',
      userId: data['userId'] ?? '',
      professionalId: data['professionalId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'userId': userId,
      'professionalId': professionalId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 