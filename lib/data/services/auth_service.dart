import 'dart:convert';

import 'package:logger/logger.dart';
import '../../app/app_config.dart';
import '../../utils/logger.dart';
import '../models/aluno.dart';
import 'storage_service.dart';
import 'api_service.dart';

class AuthService {
  final Logger _logger = getLogger('AuthService');
  final ApiService apiService;
  final StorageService storageService;

  AuthService({
    required this.apiService,
    required this.storageService,
  });

  Future<Map<String, dynamic>> login({
    required String matricula,
    required String senha
  }) async {
    try {
      // Check if user is locked out
      if (storageService.isLockedOut) {
        throw Exception('Conta temporariamente bloqueada. Tente novamente em ${storageService.remainingLockoutTime} segundos.');
      }

      final response = await apiService.post(
        AppConfig.authLogin,
        body: {
          'matricula': matricula,
          'senha': senha,
          'device_id': storageService.getDeviceId(),
        },
      );

      if (response['status'] == true) {
        // Reset login attempts on successful login
        await storageService.resetLoginAttempts();

        // Store tokens and user data
        await storageService.setAuthToken(response['data']['auth_token']);
        await storageService.setUserData(json.encode(response['data']['aluno']));
        await storageService.setLastLogin(DateTime.now());

        _logger.i('Login successful for matricula: $matricula');

        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        // Increment failed login attempts
        await storageService.incrementLoginAttempts();
        await storageService.setLastLogin(DateTime.now());

        _logger.w('Login failed for matricula: $matricula');

        return {
          'success': false,
          'message': response['message'],
          'remainingAttempts': AppConfig.maxLoginAttempts - storageService.getLoginAttempts(),
        };
      }
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      final authToken = storageService.getAuthToken();

      if (authToken != null) {
        // Call logout API if token exists
        await apiService.post(
          AppConfig.authLogout,
          authToken: authToken,
        );
      }

      // Clear local storage
      await storageService.removeAuthToken();
      await storageService.removeUserData();
      await storageService.removeRefreshToken();

      _logger.i('Logout successful');
      return true;
    } catch (e) {
      _logger.e('Logout error: $e');
      // Even if API call fails, clear local storage
      await storageService.removeAuthToken();
      await storageService.removeUserData();
      await storageService.removeRefreshToken();
      return true;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = storageService.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await apiService.post(
        AppConfig.authRefresh,
        body: {
          'refresh_token': refreshToken,
          'device_id': storageService.getDeviceId(),
        },
      );

      if (response['status'] == true) {
        await storageService.setAuthToken(response['data']['auth_token']);
        if (response['data']['refresh_token'] != null) {
          await storageService.setRefreshToken(response['data']['refresh_token']);
        }

        _logger.i('Token refreshed successfully');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> validateSession() async {
    final authToken = storageService.getAuthToken();
    final userData = storageService.getUserData();

    if (authToken == null || userData == null) {
      return {'valid': false, 'reason': 'no_tokens'};
    }

    try {
      // Simple token validation by checking expiration (if JWT)
      // In a real app, you might want to decode the JWT to check expiration
      final lastLogin = storageService.getLastLogin();
      if (lastLogin != null) {
        final sessionDuration = DateTime.now().difference(lastLogin);
        if (sessionDuration.inSeconds > AppConfig.autoLogoutTime) {
          await logout();
          return {'valid': false, 'reason': 'session_expired'};
        }
      }

      return {
        'valid': true,
        'authToken': authToken,
        'userData': json.decode(userData),
      };
    } catch (e) {
      _logger.e('Session validation error: $e');
      return {'valid': false, 'reason': 'validation_error'};
    }
  }

  bool get isAuthenticated {
    return storageService.isLoggedIn && !storageService.isLockedOut;
  }

  Map<String, dynamic>? get currentUser {
    try {
      final userData = storageService.getUserData();
      return userData != null ? json.decode(userData) : null;
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  String? get authToken {
    return storageService.getAuthToken();
  }

  // No AuthService
  Aluno? get aluno {
    final userData = currentUser;
    if (userData != null) {
      return Aluno.fromJson(userData);
    }
    return null;
  }

  Future<void> clearAuthData() async {
    await storageService.removeAuthToken();
    await storageService.removeUserData();
    await storageService.removeRefreshToken();
    _logger.i('Auth data cleared');
  }
}