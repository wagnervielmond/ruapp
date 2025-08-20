class AppConfig {
  // App Information
  static const String appName = 'RU-APP';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API Configuration
  static const String apiBaseUrl = 'https://ru.sistemasvielmond.net';
  static const String apiVersion = 'v1';
  static const int apiTimeout = 30000; // 30 seconds

  // App Settings
  static const int qrExpiryTime = 30; // seconds
  static const int authTokenExpiryTime = 3600; // 1 hour
  static const int autoLogoutTime = 1800; // 30 minutes

  // Security
  static const int maxLoginAttempts = 5;
  static const int lockoutTime = 300; // 5 minutes

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String deviceIdKey = 'device_id';
  static const String appSettingsKey = 'app_settings';
  static const String loginAttemptsKey = 'login_attempts';
  static const String lastLoginKey = 'last_login';

  // Feature Flags
  static const bool enableBiometrics = true;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;

  // App Colors
  static const int primaryColorValue = 0xFF0053A0;
  static const int accentColorValue = 0xFF00CC66;
  static const int errorColorValue = 0xFFDC3545;
  static const int successColorValue = 0xFF28A745;
  static const int warningColorValue = 0xFFFFC107;

  // App Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double buttonHeight = 50.0;

  // API Endpoints
  static String get authLogin => 'api/auth/login';
  static String get authRefresh => 'api/auth/refresh';
  static String get authLogout => 'api/auth/logout';
  static String get qrGenerate => 'api/qr/generate';
  static String get qrValidate => 'api/qr/validate';
  static String get userProfile => 'api/user/profile';
  static String get userHistory => 'api/user/history';
  static String get userBalance => 'api/user/balance';
  static String get rechargeCreate => 'api/recharge/create';

  // Localization
  static const String defaultLocale = 'pt_BR';
  static const List<String> supportedLocales = ['pt_BR', 'en_US'];

  // Build mode specific configuration
  static bool get isDebug {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }

  static String get environment {
    if (isDebug) return 'development';
    // You can add more environment detection logic here
    return 'production';
  }

  static String get fullApiUrl {
    return '$apiBaseUrl/$apiVersion';
  }

  static Map<String, String> get defaultHeaders {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': appVersion,
      'X-Platform': 'flutter',
      'X-Device-Type': 'mobile',
    };
  }
}