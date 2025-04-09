import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xclean/models/cleaning_service.dart';
import 'package:xclean/utils/constants.dart';
import 'package:xclean/services/auth_service.dart';

class CleaningServiceService {
  final _baseUrl = AppConstants.apiBaseUrl;
  final _authService = AuthService();

  Future<List<CleaningService>> getAvailableServices() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CleaningService.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar serviços');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor');
    }
  }

  Future<CleaningService> getServiceById(String id) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/services/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CleaningService.fromJson(data);
      } else {
        throw Exception('Falha ao carregar serviço');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor');
    }
  }

  Future<List<CleaningService>> getProfessionalServices(String professionalId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/professionals/$professionalId/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CleaningService.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar serviços do profissional');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor');
    }
  }

  Future<CleaningService> createService(CleaningService service) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(service.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return CleaningService.fromJson(data);
      } else {
        throw Exception('Falha ao criar serviço');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor');
    }
  }

  Future<CleaningService> updateService(CleaningService service) async {
    try {
      final token = await _authService.getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/services/${service.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(service.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CleaningService.fromJson(data);
      } else {
        throw Exception('Falha ao atualizar serviço');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor');
    }
  }

  Future<void> deleteService(String id) async {
    try {
      final token = await _authService.getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/services/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Falha ao excluir serviço');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor');
    }
  }
} 