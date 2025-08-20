import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../app/app_config.dart';
import '../../utils/logger.dart';
import '../models/acesso.dart';

class ApiService {
  final Logger _logger = getLogger('ApiService');
  final String baseUrl;

  ApiService({this.baseUrl = AppConfig.apiBaseUrl});

  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
        String? authToken,
        Map<String, String>? headers,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (authToken != null) {
        defaultHeaders['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.post(
        uri,
        headers: {...defaultHeaders, ...?headers},
        body: body != null ? json.encode(body) : null,
      );

      _logger.i('POST $endpoint - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.e('POST $endpoint error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(
      String endpoint, {
        String? authToken,
        Map<String, String>? headers,
      }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final defaultHeaders = {
        'Accept': 'application/json',
      };

      if (authToken != null) {
        defaultHeaders['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(
        uri,
        headers: {...defaultHeaders, ...?headers},
      );

      _logger.i('GET $endpoint - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _logger.e('GET $endpoint error: $e');
      rethrow;
    }
  }

  // NOVO: Método para obter histórico de acessos
  Future<List<Acesso>> obterHistoricoAcessos({
    required String authToken,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await get(
        '${AppConfig.userHistory}?limit=$limit&offset=$offset',
        authToken: authToken,
      );

      if (response['status'] == true) {
        // CORREÇÃO: Converter List<dynamic> para List<Acesso>
        final List<dynamic> dataList = response['data'] as List<dynamic>;
        return dataList.map((item) => Acesso.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response['message'] ?? 'Erro ao obter histórico');
      }
    } catch (e) {
      _logger.e('Erro ao obter histórico de acessos: $e');
      rethrow;
    }
  }

  // NOVO: Método para recarregar saldo
  Future<Map<String, dynamic>> recarregarSaldo({
    required String authToken,
    required double valor,
    required String metodo,
  }) async {
    try {
      final response = await post(
        AppConfig.rechargeCreate,
        authToken: authToken,
        body: {
          'valor': valor,
          'metodo': metodo,
        },
      );

      return response;
    } catch (e) {
      _logger.e('Erro ao recarregar saldo: $e');
      rethrow;
    }
  }

  // NOVO: Método para obter métodos de pagamento disponíveis
  Future<List<dynamic>> obterMetodosPagamento({
    required String authToken,
  }) async {
    try {
      final response = await get(
        '${AppConfig.rechargeCreate}/metodos',
        authToken: authToken,
      );

      if (response['status'] == true) {
        return response['data'] as List;
      } else {
        return [];
      }
    } catch (e) {
      _logger.e('Erro ao obter métodos de pagamento: $e');
      return [];
    }
  }

  // NOVO: Método para verificar status da recarga
  Future<Map<String, dynamic>> verificarStatusRecarga({
    required String authToken,
    required String recargaId,
  }) async {
    try {
      final response = await get(
        '${AppConfig.rechargeCreate}/status/$recargaId',
        authToken: authToken,
      );

      return response;
    } catch (e) {
      _logger.e('Erro ao verificar status da recarga: $e');
      rethrow;
    }
  }
}