import '../models/qr_response.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class QrRepository {
  final ApiService apiService;
  final StorageService? storageService;

  QrRepository(this.apiService, {this.storageService});

  Future<QrResponse> generateQrCode() async {
    try {
      final authToken = await storageService?.getAuthToken();

      final response = await apiService.post(
        'api/qr/generate',
        authToken: authToken,
        body: {
          'device_id': await storageService?.getDeviceId(),
        },
      );

      return QrResponse.fromJson(response);
    } catch (e) {
      throw Exception('Falha ao gerar QR Code: $e');
    }
  }

  Future<bool> validateQrStatus() async {
    try {
      // Implementar validação periódica do status do QR
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }
}