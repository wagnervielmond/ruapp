import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qr_provider.dart';
import '../themes/colors.dart';
import '../widgets/qr_code_widget.dart';
import '../widgets/loading_overlay.dart';
import '../../utils/helpers.dart';
import '../../data/services/auth_service.dart'; // Adicione esta importação

class QrGeneratorScreen extends StatefulWidget {
  @override
  _QrGeneratorScreenState createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  @override
  void initState() {
    super.initState();
    // Gerar QR automaticamente ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateQrCode();
    });
  }

  Future<void> _generateQrCode() async {
    final qrProvider = Provider.of<QrProvider>(context, listen: false);

    try {
      await qrProvider.generateQrCode();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar QR Code: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrProvider = Provider.of<QrProvider>(context);
    final authService = Provider.of<AuthService>(context); // Obter AuthService
    final userData = authService.currentUser; // Obter dados do usuário
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code do RU'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (qrProvider.isQrValid)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: qrProvider.canGenerateNewQr ? _generateQrCode : null,
              tooltip: 'Gerar novo QR Code',
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (qrProvider.isGenerating) ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text(
                            'Gerando QR Code...',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (qrProvider.currentQrToken != null && qrProvider.isQrValid) ...[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // QR Code
                        QrCodeWidget(
                          data: qrProvider.currentQrToken!,
                          size: 250,
                        ),

                        SizedBox(height: 30),

                        // Timer
                        Text(
                          'QR Code válido por:',
                          style: theme.textTheme.bodyLarge,
                        ),
                        SizedBox(height: 10),
                        Text(
                          qrProvider.formattedTimeRemaining, // CORREÇÃO: usar getter
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Informações do aluno (usando dados do AuthService)
                        if (userData != null)
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    userData['nome'] ?? '',
                                    style: theme.textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Matrícula: ${userData['matricula'] ?? ''}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Saldo: ${Helpers.formatCurrency(userData['saldo'] ?? 0)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Botão de ação
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: qrProvider.canGenerateNewQr ? _generateQrCode : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Gerar Novo QR Code',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 80,
                            color: theme.disabledColor,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'QR Code não disponível',
                            style: theme.textTheme.titleMedium,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Toque no botão abaixo para gerar um novo QR Code',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _generateQrCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Gerar QR Code',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (qrProvider.isGenerating) LoadingOverlay(),
        ],
      ),
    );
  }
}