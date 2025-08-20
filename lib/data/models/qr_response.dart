class QrResponse {
  final bool success;
  final String message;
  final String? qrToken;
  final int expiresIn;
  final Map<String, dynamic>? alunoData;

  QrResponse({
    required this.success,
    required this.message,
    this.qrToken,
    this.expiresIn = 30,
    this.alunoData,
  });

  factory QrResponse.fromJson(Map<String, dynamic> json) {
    return QrResponse(
      success: json['status'] ?? false,
      message: json['message'] ?? '',
      qrToken: json['data']['qr_token'],
      expiresIn: json['data']['expires_in'] ?? 30,
      alunoData: json['data']['aluno'],
    );
  }
}