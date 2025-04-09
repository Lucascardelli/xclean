import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reviews';

  Future<Review> createReview(Review review) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add(review.toMap());
      return Review.fromFirestore(await docRef.get());
    } catch (e) {
      throw Exception('Erro ao criar avaliação: $e');
    }
  }

  Future<List<Review>> getProfessionalReviews(String professionalId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('professionalId', isEqualTo: professionalId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar avaliações: $e');
    }
  }

  Future<double> getProfessionalAverageRating(String professionalId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('professionalId', isEqualTo: professionalId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      double totalRating = 0;
      for (var doc in snapshot.docs) {
        Review review = Review.fromFirestore(doc);
        totalRating += review.rating;
      }

      return totalRating / snapshot.docs.length;
    } catch (e) {
      throw Exception('Erro ao calcular média de avaliações: $e');
    }
  }
} 