import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userType; // 'client' ou 'professional'
  final String? photoUrl;
  final GeoPoint? location;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final double? rating;
  final int? totalReviews;
  final List<String>? services;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.photoUrl,
    this.location,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.rating,
    this.totalReviews,
    this.services,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      userType: data['userType'] ?? 'client',
      photoUrl: data['photoUrl'],
      location: data['location'] as GeoPoint?,
      address: data['address'],
      city: data['city'],
      state: data['state'],
      zipCode: data['zipCode'],
      rating: data['rating']?.toDouble(),
      totalReviews: data['totalReviews'],
      services: data['services'] != null ? List<String>.from(data['services']) : null,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType,
      'photoUrl': photoUrl,
      'location': location,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'rating': rating,
      'totalReviews': totalReviews,
      'services': services,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
} 