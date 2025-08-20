import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../data/repositories/auth_repository.dart';
import '../../utils/logger.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository authRepository;
  final Logger _logger = getLogger('AuthProvider');

  // Estados de autenticação
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _loginAttempts = 0;
  DateTime? _lastLoginAttempt;

  AuthProvider({required this.authRepository}) {
    _initialize();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get loginAttempts => _loginAttempts;
  DateTime? get lastLoginAttempt => _lastLoginAttempt;

  // Inicialização
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Verificar se há sessão válida
      final sessionValid = await authRepository.isSessionValid();
      _isAuthenticated = sessionValid;

      _logger.i('Auth initialized: $_isAuthenticated');
    } catch (e) {
      _logger.e('Error during auth initialization: $e');
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String matricula, String senha) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await authRepository.login(matricula, senha);

      if (response.success) {
        _isAuthenticated = true;
        _loginAttempts = 0;
        _lastLoginAttempt = DateTime.now();
        _errorMessage = null;

        _logger.i('Login successful for matricula: $matricula');
        notifyListeners();
        return true;
      } else {
        _isAuthenticated = false;
        _errorMessage = response.message;
        _loginAttempts = authRepository.getRemainingLoginAttempts();
        _lastLoginAttempt = DateTime.now();

        _logger.w('Login failed: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'Erro de conexão. Tente novamente.';
      _loginAttempts++;
      _lastLoginAttempt = DateTime.now();

      _logger.e('Login error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Logout
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await authRepository.logout();
      if (success) {
        _isAuthenticated = false;
        _errorMessage = null;
        _loginAttempts = 0;
        _lastLoginAttempt = null;

        _logger.i('Logout successful');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Logout error: $e');
      // Forçar logout local mesmo com erro
      _isAuthenticated = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final response = await authRepository.refreshToken();
      _isAuthenticated = response.success;

      if (response.success) {
        _logger.i('Token refreshed successfully');
      } else {
        _logger.w('Token refresh failed: ${response.message}');
      }

      notifyListeners();
      return response.success;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  // Validar sessão
  Future<bool> validateSession() async {
    try {
      final isValid = await authRepository.isSessionValid();
      _isAuthenticated = isValid;

      if (!isValid) {
        _logger.w('Session validation failed');
      }

      notifyListeners();
      return isValid;
    } catch (e) {
      _logger.e('Session validation error: $e');
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  // Limpar erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Obter dados do usuário atual
  Map<String, dynamic>? get currentUser {
    return authRepository.getCurrentUser();
  }

  // Verificar se está bloqueado
  bool get isLockedOut {
    return authRepository.getRemainingLockoutTime() > 0;
  }

  // Tempo restante de bloqueio
  int get remainingLockoutTime {
    return authRepository.getRemainingLockoutTime();
  }

  // Formatar tempo de bloqueio
  String get formattedLockoutTime {
    final seconds = remainingLockoutTime;
    if (seconds <= 0) return '';

    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  // Disposer
  @override
  void dispose() {
    _logger.i('AuthProvider disposed');
    super.dispose();
  }
}