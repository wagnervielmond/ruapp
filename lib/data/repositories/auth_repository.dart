import 'dart:convert';

import 'package:logger/Logger.dart';
import '../../app/app_config.dart';
import '../../utils/logger.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/auth_response.dart';

class AuthRepository {
  final Logger _logger = getLogger('AuthRepository');
  final ApiService apiService;
  final StorageService storageService;

  AuthRepository(this.apiService, this.storageService);

  Future<AuthResponse> login(String matricula, String senha) async {
    try {
      final response = await apiService.post(
        AppConfig.authLogin,
        body: {
          'matricula': matricula,
          'senha': senha,
          'device_id': storageService.getDeviceId(),
        },
      );

      final authResponse = AuthResponse.fromJson(response);

      if (authResponse.success) {
        // Store tokens and user data
        await storageService.setAuthToken(authResponse.authToken!);
        await storageService.setUserData(json.encode(authResponse.userData));
        await storageService.setLastLogin(DateTime.now());
        await storageService.resetLoginAttempts();

        _logger.i('Login successful for matricula: $matricula');
      } else {
        // Handle failed login
        await storageService.incrementLoginAttempts();
        await storageService.setLastLogin(DateTime.now());

        _logger.w('Login failed for matricula: $matricula');
      }

      return authResponse;
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      final authToken = storageService.getAuthToken();

      if (authToken != null) {
        try {
          await apiService.post(
            AppConfig.authLogout,
            authToken: authToken,
            body: {
              'device_id': storageService.getDeviceId(),
            },
          );
        } catch (e) {
          _logger.w('Logout API call failed, but proceeding with local cleanup: $e');
        }
      }

      // Clear local storage regardless of API call success
      await storageService.clearAll();

      _logger.i('Logout completed');
      return true;
    } catch (e) {
      _logger.e('Logout error: $e');
      return false;
    }
  }

  Future<AuthResponse> refreshToken() async {
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

      final authResponse = AuthResponse.fromJson(response);

      if (authResponse.success) {
        await storageService.setAuthToken(authResponse.authToken!);
        if (response['data']['refresh_token'] != null) {
          await storageService.setRefreshToken(response['data']['refresh_token']);
        }

        _logger.i('Token refreshed successfully');
      }

      return authResponse;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      rethrow;
    }
  }

  Future<bool> validateAuthToken() async {
    try {
      final authToken = storageService.getAuthToken();
      if (authToken == null) return false;

      // Simple validation by making a test API call
      final response = await apiService.get(
        '${AppConfig.userProfile}/validate',
        authToken: authToken,
      );

      return response['status'] == true;
    } catch (e) {
      _logger.e('Token validation error: $e');
      return false;
    }
  }

  Future<bool> isSessionValid() async {
    if (!storageService.isLoggedIn) return false;

    if (storageService.isLockedOut) return false;

    // Check if session has expired
    final lastLogin = storageService.getLastLogin();
    if (lastLogin != null) {
      final sessionDuration = DateTime.now().difference(lastLogin);
      if (sessionDuration.inSeconds > AppConfig.autoLogoutTime) {
        await logout();
        return false;
      }
    }

    // Validate token with server if needed
    return await validateAuthToken();
  }

  Map<String, dynamic>? getCurrentUser() {
    try {
      final userData = storageService.getUserData();
      return userData != null ? json.decode(userData) : null;
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  int getRemainingLoginAttempts() {
    return AppConfig.maxLoginAttempts - storageService.getLoginAttempts();
  }

  int getRemainingLockoutTime() {
    return storageService.remainingLockoutTime;
  }

  Future<void> clearAuthData() async {
    await storageService.clearAll();
    _logger.i('All auth data cleared');
  }
}