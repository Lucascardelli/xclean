import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled
}

class Appointment {
  final String id;
  final String userId;
  final String service;
  final DateTime date;
  final String time;
  final String status;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.service,
    required this.date,
    required this.time,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Appointment(
      id: doc.id,
      userId: data['userId'] ?? '',
      service: data['service'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      status: data['status'] ?? 'pending',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'service': service,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 