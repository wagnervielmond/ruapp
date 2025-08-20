import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../data/repositories/qr_repository.dart';
import '../../utils/logger.dart';

class QrProvider with ChangeNotifier {
  final QrRepository qrRepository; // CORREÇÃO: Usar o repositório
  final Logger _logger = getLogger('QrProvider');

  // Estados do QR Code
  String? _currentQrToken;
  DateTime? _qrGeneratedAt;
  int _remainingSeconds = 0;
  bool _isGenerating = false;
  bool _isValidating = false;
  String? _errorMessage;
  String? _lastValidationStatus;

  QrProvider({required this.qrRepository}); // CORREÇÃO: Receber o repositório

  // Getters
  String? get currentQrToken => _currentQrToken;
  DateTime? get qrGeneratedAt => _qrGeneratedAt;
  int get remainingSeconds => _remainingSeconds;
  bool get isGenerating => _isGenerating;
  bool get isValidating => _isValidating;
  String? get errorMessage => _errorMessage;
  String? get lastValidationStatus => _lastValidationStatus;
  bool get isQrValid => _remainingSeconds > 0;

  // Gerar QR Code - CORRIGIDO
  Future<bool> generateQrCode() async {
    if (_isGenerating) return false;

    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await qrRepository.generateQrCode(); // CORREÇÃO: Usar repositório

      if (response.success && response.qrToken != null) {
        _currentQrToken = response.qrToken;
        _qrGeneratedAt = DateTime.now();
        _startCountdown(response.expiresIn);

        _logger.i('QR Code gerado com sucesso. Expires in: ${response.expiresIn}s');
        return true;
      } else {
        _errorMessage = response.message;
        _logger.w('QR Generation failed: ${response.message}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao gerar QR Code';
      _logger.e('QR Generation error: $e');
      return false;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // Iniciar contagem regressiva
  void _startCountdown(int expiresIn) {
    _remainingSeconds = expiresIn;

    // Atualizar contador a cada segundo
    Future.doWhile(() async {
      if (_remainingSeconds > 0) {
        await Future.delayed(const Duration(seconds: 1));
        _remainingSeconds--;
        notifyListeners();
        return true;
      } else {
        // QR Code expirado
        _currentQrToken = null;
        _qrGeneratedAt = null;
        notifyListeners();
        return false;
      }
    });
  }

  // Validar status do QR Code - CORRIGIDO
  Future<bool> validateQrStatus() async {
    if (_isValidating || _currentQrToken == null) return false;

    _isValidating = true;
    notifyListeners();

    try {
      final isValid = await qrRepository.validateQrStatus(); // CORREÇÃO: Usar repositório
      _lastValidationStatus = isValid ? 'valid' : 'invalid';

      _logger.i('QR Validation status: $_lastValidationStatus');
      return isValid;
    } catch (e) {
      _lastValidationStatus = 'error';
      _logger.e('QR Validation error: $e');
      return false;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  // Limpar QR Code atual
  void clearQrCode() {
    _currentQrToken = null;
    _qrGeneratedAt = null;
    _remainingSeconds = 0;
    _errorMessage = null;
    _lastValidationStatus = null;
    notifyListeners();
  }

  // Formatar tempo restante
  String get formattedTimeRemaining {
    if (_remainingSeconds <= 0) return '00:00';

    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Verificar se pode gerar novo QR
  bool get canGenerateNewQr {
    return !_isGenerating && (_remainingSeconds <= 5 || _currentQrToken == null);
  }

  // Obter progresso da geração (para animações)
  double get generationProgress {
    if (_currentQrToken == null) return 0.0;
    if (_remainingSeconds <= 0) return 0.0;

    const totalTime = 30; // 30 segundos
    return _remainingSeconds / totalTime;
  }

  // Limpar erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Disposer
  @override
  void dispose() {
    _logger.i('QrProvider disposed');
    super.dispose();
  }
}