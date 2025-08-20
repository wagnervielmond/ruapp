import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../app/app_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth Token
  Future<void> setAuthToken(String token) async {
    await _prefs.setString(AppConfig.authTokenKey, token);
  }

  String? getAuthToken() {
    return _prefs.getString(AppConfig.authTokenKey);
  }

  Future<void> removeAuthToken() async {
    await _prefs.remove(AppConfig.authTokenKey);
  }

  // Refresh Token
  Future<void> setRefreshToken(String token) async {
    await _prefs.setString(AppConfig.refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return _prefs.getString(AppConfig.refreshTokenKey);
  }

  Future<void> removeRefreshToken() async {
    await _prefs.remove(AppConfig.refreshTokenKey);
  }

  // User Data
  Future<void> setUserData(String userData) async {
    await _prefs.setString(AppConfig.userDataKey, userData);
  }

  String? getUserData() {
    return _prefs.getString(AppConfig.userDataKey);
  }

  Future<void> removeUserData() async {
    await _prefs.remove(AppConfig.userDataKey);
  }

  // Device ID
  Future<void> setDeviceId(String deviceId) async {
    await _prefs.setString(AppConfig.deviceIdKey, deviceId);
  }

  String getDeviceId() {
    return _prefs.getString(AppConfig.deviceIdKey) ?? _generateDeviceId();
  }

  String _generateDeviceId() {
    final newDeviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    setDeviceId(newDeviceId);
    return newDeviceId;
  }

  // Login Attempts
  Future<void> setLoginAttempts(int attempts) async {
    await _prefs.setInt(AppConfig.loginAttemptsKey, attempts);
  }

  int getLoginAttempts() {
    return _prefs.getInt(AppConfig.loginAttemptsKey) ?? 0;
  }

  Future<void> incrementLoginAttempts() async {
    final attempts = getLoginAttempts() + 1;
    await setLoginAttempts(attempts);
  }

  Future<void> resetLoginAttempts() async {
    await _prefs.remove(AppConfig.loginAttemptsKey);
  }

  // Last Login
  Future<void> setLastLogin(DateTime dateTime) async {
    await _prefs.setString(AppConfig.lastLoginKey, dateTime.toIso8601String());
  }

  DateTime? getLastLogin() {
    final dateString = _prefs.getString(AppConfig.lastLoginKey);
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  // App Settings
  Future<void> setAppSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(AppConfig.appSettingsKey, json.encode(settings));
  }

  Map<String, dynamic> getAppSettings() {
    final settingsString = _prefs.getString(AppConfig.appSettingsKey);
    if (settingsString != null) {
      return json.decode(settingsString);
    }
    return {};
  }

  // Generic methods
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  Future<void> removeKey(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Check if user is logged in
  bool get isLoggedIn {
    return getAuthToken() != null && getUserData() != null;
  }

  // Check if user should be locked out
  bool get isLockedOut {
    final attempts = getLoginAttempts();
    final lastAttempt = getLastLogin();

    if (attempts >= AppConfig.maxLoginAttempts && lastAttempt != null) {
      final lockoutEnd = lastAttempt.add(Duration(seconds: AppConfig.lockoutTime));
      return DateTime.now().isBefore(lockoutEnd);
    }

    return false;
  }

  // Get remaining lockout time
  int get remainingLockoutTime {
    final lastAttempt = getLastLogin();
    if (lastAttempt != null && isLockedOut) {
      final lockoutEnd = lastAttempt.add(Duration(seconds: AppConfig.lockoutTime));
      return lockoutEnd.difference(DateTime.now()).inSeconds;
    }
    return 0;
  }
}