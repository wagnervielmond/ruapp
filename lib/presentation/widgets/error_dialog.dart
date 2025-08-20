import 'package:flutter/material.dart';

import '../themes/colors.dart';
import '../themes/text_styles.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String retryText;
  final String dismissText;

  const ErrorDialog({
    super.key,
    required this.message,
    this.title = 'Ops! Algo deu errado',
    this.details,
    this.onRetry,
    this.onDismiss,
    this.retryText = 'Tentar Novamente',
    this.dismissText = 'Fechar',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone e Título
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 32,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Mensagem de erro
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),

            // Detalhes do erro (se disponível)
            if (details != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  _showErrorDetails(context, details!);
                },
                child: Text(
                  'Ver detalhes do erro',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botão de Fechar
                if (onDismiss != null || onRetry == null)
                  TextButton(
                    onPressed: onDismiss ?? () => Navigator.pop(context),
                    child: Text(
                      dismissText,
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                // Botão de Tentar Novamente
                if (onRetry != null) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onRetry!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: Text(retryText),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDetails(BuildContext context, String details) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalhes do Erro',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: SelectableText(
                  details,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontFamily: 'Monospace',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos estáticos para facilitar o uso

  static void show({
    required BuildContext context,
    required String message,
    String? title,
    String? details,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    String? retryText,
    String? dismissText,
  }) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title ?? 'Ops! Algo deu errado',
        message: message,
        details: details,
        onRetry: onRetry,
        onDismiss: onDismiss,
        retryText: retryText ?? 'Tentar Novamente',
        dismissText: dismissText ?? 'Fechar',
      ),
    );
  }

  static void showNetworkError(BuildContext context, {VoidCallback? onRetry}) {
    show(
      context: context,
      title: 'Erro de Conexão',
      message: 'Não foi possível conectar ao servidor. '
          'Verifique sua conexão com a internet e tente novamente.',
      onRetry: onRetry,
    );
  }

  static void showServerError(BuildContext context, {VoidCallback? onRetry}) {
    show(
      context: context,
      title: 'Erro do Servidor',
      message: 'O servidor está enfrentando problemas temporários. '
          'Por favor, tente novamente em alguns instantes.',
      onRetry: onRetry,
    );
  }

  static void showAuthenticationError(BuildContext context) {
    show(
      context: context,
      title: 'Sessão Expirada',
      message: 'Sua sessão expirou. Por favor, faça login novamente.',
      dismissText: 'Fazer Login',
      onDismiss: () {
        Navigator.pop(context);
        // Navegar para tela de login
        // Navigator.pushReplacementNamed(context, '/login');
      },
    );
  }

  static void showValidationError(BuildContext context, String field) {
    show(
      context: context,
      title: 'Dados Inválidos',
      message: 'Por favor, verifique o campo "$field" e tente novamente.',
    );
  }

  static void showPermissionError(BuildContext context, String permission) {
    show(
      context: context,
      title: 'Permissão Necessária',
      message: 'É necessário conceder permissão para $permission '
          'para utilizar esta funcionalidade.',
      dismissText: 'Configurações',
      onDismiss: () {
        Navigator.pop(context);
        // Abrir configurações do app
        // AppSettings.openAppSettings();
      },
    );
  }

  // Builder para uso com FutureBuilder e StreamBuilder
  static Widget builder({
    required AsyncSnapshot snapshot,
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    if (snapshot.hasError) {
      return Center(
        child: ErrorDialog(
          title: 'Erro ao Carregar',
          message: customMessage ?? 'Ocorreu um erro ao carregar os dados.',
          details: snapshot.error.toString(),
          onRetry: onRetry,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // SnackBar de erro rápido
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Extensão para facilitar o uso do ErrorDialog
extension ErrorDialogExtension on BuildContext {
  void showErrorDialog({
    required String message,
    String? title,
    String? details,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    ErrorDialog.show(
      context: this,
      message: message,
      title: title,
      details: details,
      onRetry: onRetry,
      onDismiss: onDismiss,
    );
  }

  void showNetworkErrorDialog({VoidCallback? onRetry}) {
    ErrorDialog.showNetworkError(this, onRetry: onRetry);
  }

  void showServerErrorDialog({VoidCallback? onRetry}) {
    ErrorDialog.showServerError(this, onRetry: onRetry);
  }
}