class AuthResponse {
  final bool success;
  final String message;
  final String? authToken;
  final Map<String, dynamic>? userData;
  final int expiresIn;

  AuthResponse({
    required this.success,
    required this.message,
    this.authToken,
    this.userData,
    this.expiresIn = 3600,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['status'] ?? false,
      message: json['message'] ?? '',
      authToken: json['data']['auth_token'],
      userData: json['data']['aluno'],
      expiresIn: json['data']['expires_in'] ?? 3600,
    );
  }
}