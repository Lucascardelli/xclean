import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/stripe_config.dart';
import '../utils/constants.dart';

class PaymentService {
  final String baseUrl = AppConstants.apiBaseUrl;

  Future<Map<String, dynamic>> createPaymentIntent({
    required String appointmentId,
    required int amount,
    required String currency,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/create-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'appointmentId': appointmentId,
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao criar intenção de pagamento');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paymentIntentId': paymentIntentId,
          'paymentMethodId': paymentMethodId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao confirmar pagamento');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/methods'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao carregar métodos de pagamento');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<Map<String, dynamic>> savePaymentMethod({
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/methods'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paymentMethodId': paymentMethodId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao salvar método de pagamento');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<Map<String, dynamic>> deletePaymentMethod({
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/payments/methods/$paymentMethodId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao excluir método de pagamento');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<Map<String, dynamic>> requestRefund({
    required String paymentIntentId,
    required int amount,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/refund'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paymentIntentId': paymentIntentId,
          'amount': amount,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao solicitar reembolso');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<Map<String, dynamic>> getPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/history'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao carregar histórico de pagamentos');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }
} 