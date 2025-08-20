import 'dart:convert';

import 'package:logger/logger.dart';
import '../../app/app_config.dart';
import '../models/acesso.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/aluno.dart';
import '../../utils/logger.dart';

class UserRepository {
  final Logger _logger = getLogger('UserRepository');
  final ApiService apiService;
  final StorageService? storageService;

  UserRepository(this.apiService, {this.storageService});

  Future<Aluno?> getProfile() async {
    try {
      final authToken = await storageService?.getAuthToken();

      final response = await apiService.get(
        'api/user/profile',
        authToken: authToken,
      );

      if (response['status'] == true) {
        return Aluno.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      _logger.e('Error getting profile: $e');
      rethrow;
    }
  }

  // Future<Aluno?> getProfile() async {
  //   try {
  //     final authToken = await storageService?.getAuthToken();
  //
  //     final response = await apiService.get(
  //       AppConfig.userProfile,
  //       authToken: authToken,
  //     );
  //
  //     if (response['status'] == true) {
  //       return Aluno.fromJson(response['data']);
  //     }
  //
  //     return null;
  //   } catch (e) {
  //     _logger.e('Error getting profile: $e');
  //     rethrow;
  //   }
  // }

  Future<List<Acesso>> getAccessHistory({int limit = 20, int offset = 0}) async {
    try {
      final authToken = await storageService?.getAuthToken();

      final response = await apiService.get(
        '${AppConfig.userHistory}?limit=$limit&offset=$offset',
        authToken: authToken,
      );

      if (response['status'] == true) {
        return (response['data'] as List)
            .map((item) => Acesso.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      _logger.e('Error getting access history: $e');
      return [];
    }
  }

  Future<double> getBalance() async {
    try {
      final authToken = await storageService?.getAuthToken();

      final response = await apiService.get(
        AppConfig.userBalance,
        authToken: authToken,
      );

      if (response['status'] == true) {
        return double.parse(response['data']['saldo'].toString());
      }

      return 0.0;
    } catch (e) {
      _logger.e('Error getting balance: $e');
      return 0.0;
    }
  }

  Future<List<Acesso>> obterHistoricoAcessos({int limit = 20, int offset = 0}) async {
    try {
      final authToken = await storageService?.getAuthToken();

      if (authToken == null) {
        throw Exception('Token de autenticação não disponível');
      }

      final response = await apiService.obterHistoricoAcessos(
        authToken: authToken,
        limit: limit,
        offset: offset,
      );

      // CORREÇÃO: Já recebemos List<Acesso> do apiService, então retornamos diretamente
      return response;
    } catch (e) {
      _logger.e('Error getting access history: $e');
      return [];
    }
  }

  Future<bool> rechargeBalance(double amount) async {
    try {
      final authToken = await storageService?.getAuthToken();

      final response = await apiService.post(
        AppConfig.rechargeCreate,
        authToken: authToken,
        body: {
          'valor': amount,
          'metodo': 'pix', // Default method
        },
      );

      return response['status'] == true;
    } catch (e) {
      _logger.e('Error recharging balance: $e');
      rethrow;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      final authToken = await storageService?.getAuthToken();

      final response = await apiService.post(
        '${AppConfig.userProfile}/update',
        authToken: authToken,
        body: updates,
      );

      if (response['status'] == true && storageService != null) {
        // Update local storage
        final currentUser = storageService!.getUserData();
        if (currentUser != null) {
          final userData = json.decode(currentUser);
          final updatedUser = {...userData, ...updates};
          await storageService!.setUserData(json.encode(updatedUser));
        }

        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error updating profile: $e');
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final authToken = await storageService?.getAuthToken();

      final response = await apiService.post(
        '${AppConfig.userProfile}/change-password',
        authToken: authToken,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      return response['status'] == true;
    } catch (e) {
      _logger.e('Error changing password: $e');
      rethrow;
    }
  }
}