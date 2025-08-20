import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:logger/Logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../app/app_config.dart';
import '../../utils/logger.dart';

class QRService {
  final Logger _logger = getLogger('QRService');
  QRViewController? _qrViewController;
  Barcode? _lastResult;

  // Configurações do scanner
  static final _scanSettings = {
    'formats': [BarcodeFormat.qrcode],
    'facing': CameraFacing.back,
  };

  Future<String?> scanQR() async {
    try {
      _logger.i('Iniciando leitura de QR Code');

      // Em produção real, isso seria implementado com uma câmera real
      // Para demonstração, vamos simular um token QR
      await Future.delayed(const Duration(seconds: 2));

      final simulatedToken = _generateSimulatedToken();
      _logger.i('QR Code simulado gerado: $simulatedToken');

      return simulatedToken;
    } on PlatformException catch (e) {
      _logger.e('Erro ao escanear QR Code: $e');
      throw Exception('Erro ao acessar a câmera: ${e.message}');
    } catch (e) {
      _logger.e('Erro inesperado ao escanear QR: $e');
      throw Exception('Falha ao escanear QR Code');
    }
  }

  String _generateSimulatedToken() {
    // Simular um token JWT para demonstração
    final payload = {
      'aluno_id': 1,
      'matricula': '202311111',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'exp': DateTime.now().add(const Duration(seconds: 30)).millisecondsSinceEpoch,
      'device_id': 'simulated_device'
    };

    final payloadBase64 = _base64Encode(json.encode(payload));
    return 'simulated.$payloadBase64.token';
  }

  String _base64Encode(String input) {
    final bytes = utf8.encode(input);
    return base64.encode(bytes);
  }

  // Métodos para uso com câmera real (implementação futura)
  Future<void> initializeController(QRViewController controller) async {
    _qrViewController = controller;

    // Configurar o scanner
    await controller.resumeCamera();
    await controller.toggleFlash();
    await controller.flipCamera();

    _logger.i('Controlador de QR Code inicializado');
  }

  Future<void> disposeController() async {
    _qrViewController?.dispose(); // Remove o await
    _qrViewController = null;
    _logger.i('Controlador de QR Code disposed');
  }

  Future<String?> scanWithCamera() async {
    if (_qrViewController == null) {
      throw Exception('Controlador de câmera não inicializado');
    }

    try {
      // Escutar por resultados do scanner
      final stream = _qrViewController!.scannedDataStream;
      final result = await stream.first;

      if (result.code != null) {
        _lastResult = result;
        _logger.i('QR Code detectado: ${result.code}');
        return result.code;
      }

      return null;
    } catch (e) {
      _logger.e('Erro durante escaneamento: $e');
      return null;
    }
  }

  Future<void> pauseCamera() async {
    await _qrViewController?.pauseCamera();
  }

  Future<void> resumeCamera() async {
    await _qrViewController?.resumeCamera();
  }

  Future<void> toggleFlash() async {
    await _qrViewController?.toggleFlash();
  }

  Future<void> flipCamera() async {
    await _qrViewController?.flipCamera();
  }

  // Métodos para obter informações do scanner
  bool get isCameraInitialized => _qrViewController != null;
  Barcode? get lastResult => _lastResult;

  // Método para validar o formato do token QR
  bool isValidQRToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      // Verificar se é um token simulado ou JWT válido
      if (token.startsWith('simulated.')) {
        return true;
      }

      // Aqui você pode adicionar validações adicionais para tokens JWT reais
      return true;
    } catch (e) {
      return false;
    }
  }

  // Método para decodificar token QR (se necessário)
  Map<String, dynamic>? decodeQRToken(String token) {
    try {
      if (token.startsWith('simulated.')) {
        final parts = token.split('.');
        if (parts.length >= 2) {
          final decoded = _base64Decode(parts[1]);
          return json.decode(decoded) as Map<String, dynamic>;
        }
      }

      // Para tokens JWT reais, você usaria um pacote JWT
      return null;
    } catch (e) {
      _logger.e('Erro ao decodificar token QR: $e');
      return null;
    }
  }

  String _base64Decode(String input) {
    final bytes = base64.decode(input);
    return utf8.decode(bytes);
  }

  void dispose() {
    _qrViewController?.dispose();
    _logger.i('QRService disposed');
  }
}

// Classe para geração de QR Code (se necessário no futuro)
class QRGeneratorService {
  static String generateAuthToken(String alunoId, String deviceId) {
    final payload = {
      'aluno_id': alunoId,
      'device_id': deviceId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'exp': DateTime.now().add(const Duration(seconds: AppConfig.qrExpiryTime)).millisecondsSinceEpoch,
    };

    // Em produção, usaríamos JWT com assinatura
    final payloadBase64 = base64.encode(utf8.encode(json.encode(payload)));
    return 'qr.$payloadBase64.token';
  }

  static bool validateQRToken(String token, String expectedDeviceId) {
    try {
      if (!token.startsWith('qr.')) return false;

      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payloadJson = utf8.decode(base64.decode(parts[1]));
      final payload = json.decode(payloadJson) as Map<String, dynamic>;

      // Verificar expiração
      final exp = payload['exp'] as int;
      if (DateTime.now().millisecondsSinceEpoch > exp) {
        return false;
      }

      // Verificar device ID
      if (payload['device_id'] != expectedDeviceId) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}