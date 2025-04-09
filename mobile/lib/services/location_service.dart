import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Solicitar permissão de localização
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Solicitar permissão
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Obter localização atual
  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  // Atualizar localização do usuário
  Future<void> updateUserLocation(String userId, Position position) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': GeoPoint(position.latitude, position.longitude),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar localização: $e');
    }
  }

  // Calcular distância entre dois pontos
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Buscar profissionais próximos
  Future<List<User>> getNearbyProfessionals({
    required double latitude,
    required double longitude,
    double maxDistanceInKm = 10.0,
    List<String>? services,
    double? minRating,
  }) async {
    try {
      // Converter km para metros
      final maxDistanceInMeters = maxDistanceInKm * 1000;
      
      // Buscar todos os profissionais
      Query query = _firestore.collection('users')
          .where('userType', isEqualTo: 'professional')
          .where('isAvailable', isEqualTo: true);
      
      // Aplicar filtro de serviços se fornecido
      if (services != null && services.isNotEmpty) {
        query = query.where('services', arrayContainsAny: services);
      }
      
      // Aplicar filtro de avaliação mínima se fornecido
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }
      
      final QuerySnapshot snapshot = await query.get();
      
      // Filtrar por distância
      List<User> nearbyProfessionals = [];
      for (var doc in snapshot.docs) {
        final user = User.fromFirestore(doc);
        
        if (user.location != null) {
          final distance = calculateDistance(
            latitude, 
            longitude, 
            user.location!.latitude, 
            user.location!.longitude
          );
          
          if (distance <= maxDistanceInMeters) {
            nearbyProfessionals.add(user);
          }
        }
      }
      
      // Ordenar por distância
      nearbyProfessionals.sort((a, b) {
        final distanceA = calculateDistance(
          latitude, 
          longitude, 
          a.location!.latitude, 
          a.location!.longitude
        );
        
        final distanceB = calculateDistance(
          latitude, 
          longitude, 
          b.location!.latitude, 
          b.location!.longitude
        );
        
        return distanceA.compareTo(distanceB);
      });
      
      return nearbyProfessionals;
    } catch (e) {
      throw Exception('Erro ao buscar profissionais próximos: $e');
    }
  }
} 