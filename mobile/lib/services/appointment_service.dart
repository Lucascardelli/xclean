import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'appointments';

  Future<Appointment> createAppointment(Appointment appointment) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add(appointment.toMap());
      return Appointment.fromFirestore(await docRef.get());
    } catch (e) {
      throw Exception('Erro ao criar agendamento: $e');
    }
  }

  Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos: $e');
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointmentId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Erro ao atualizar status do agendamento: $e');
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointmentId)
          .update({'status': 'cancelled'});
    } catch (e) {
      throw Exception('Erro ao cancelar agendamento: $e');
    }
  }
} 