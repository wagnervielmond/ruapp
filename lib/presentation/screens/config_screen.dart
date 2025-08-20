import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/services/auth_service.dart';
import '../../utils/constants.dart';
import '../providers/theme_provider.dart';
import '../widgets/setting_tile.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(Constants.defaultPadding),
        children: [
          // Seção de Conta
          _buildSectionHeader('Conta'),
          SettingTile(
            icon: Icons.person,
            title: 'Meus Dados',
            subtitle: 'Visualizar informações da conta',
            onTap: () => _navigateToProfile(context),
          ),
          SettingTile(
            icon: Icons.history,
            title: 'Histórico de Uso',
            subtitle: 'Consultar refeições realizadas',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 16),

          // Seção de Aparência
          _buildSectionHeader('Aparência'),
          SettingTile(
            icon: Icons.dark_mode,
            title: 'Tema Escuro',
            subtitle: themeProvider.isDarkMode ? 'Ativado' : 'Desativado',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
              activeColor: theme.primaryColor,
            ),
          ),
          SettingTile(
            icon: Icons.qr_code,
            title: 'Auto-geração de QR Code',
            subtitle: 'Gerar QR automaticamente ao abrir o app',
            trailing: Switch(
              value: true,
              onChanged: (value) => _showComingSoon(context),
              activeColor: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Seção de Notificações
          _buildSectionHeader('Notificações'),
          SettingTile(
            icon: Icons.notifications,
            title: 'Notificações Push',
            subtitle: 'Receber alertas e lembretes',
            trailing: Switch(
              value: true,
              onChanged: (value) => _showComingSoon(context),
              activeColor: theme.primaryColor,
            ),
          ),
          SettingTile(
            icon: Icons.account_balance_wallet,
            title: 'Alertas de Saldo',
            subtitle: 'Avisos quando o saldo estiver baixo',
            trailing: Switch(
              value: true,
              onChanged: (value) => _showComingSoon(context),
              activeColor: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Seção de Ajuda
          _buildSectionHeader('Ajuda e Suporte'),
          SettingTile(
            icon: Icons.help,
            title: 'Perguntas Frequentes',
            subtitle: 'Tire suas dúvidas',
            onTap: () => _launchExternalUrl(context, 'https://universidade.edu.br/ru/faq'),
          ),
          SettingTile(
            icon: Icons.contact_support,
            title: 'Suporte',
            subtitle: 'Entre em contato conosco',
            onTap: () => _launchEmail(context, 'suporte-ru@universidade.edu.br'),
          ),
          SettingTile(
            icon: Icons.privacy_tip,
            title: 'Política de Privacidade',
            subtitle: 'Como protegemos seus dados',
            onTap: () => _launchExternalUrl(context, 'https://universidade.edu.br/ru/politica-privacidade'),
          ),
          SettingTile(
            icon: Icons.description,
            title: 'Termos de Uso',
            subtitle: 'Termos e condições do aplicativo',
            onTap: () => _launchExternalUrl(context, 'https://universidade.edu.br/ru/termos-uso'),
          ),
          const SizedBox(height: 16),

          // Seção Sobre
          _buildSectionHeader('Sobre'),
          SettingTile(
            icon: Icons.info,
            title: 'Versão do App',
            subtitle: '1.0.0 (Build 1)',
            onTap: () => _showAppInfo(context),
          ),
          SettingTile(
            icon: Icons.update,
            title: 'Atualizações',
            subtitle: 'Verificar atualizações disponíveis',
            onTap: () => _checkForUpdates(context),
          ),
          const SizedBox(height: 24),

          // Botão de Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sair da Conta'),
              onPressed: () => _showLogoutConfirmation(context, authService),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recurso em Desenvolvimento'),
        content: const Text('Esta funcionalidade estará disponível em breve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        _showUrlError(context, url);
      }
    } catch (e) {
      _showUrlError(context, url);
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    try {
      if (!await launchUrl(uri)) {
        _showUrlError(context, email);
      }
    } catch (e) {
      _showUrlError(context, email);
    }
  }

  void _showUrlError(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro ao abrir link'),
        content: Text('Não foi possível abrir: $url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informações do App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RU-APP - Restaurante Universitário', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Versão: 1.0.0 (Build 1)'),
            Text('Desenvolvido para: Universidade Federal'),
            SizedBox(height: 16),
            Text('© 2024 Universidade Federal. Todos os direitos reservados.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verificar Atualizações'),
        content: const Text('Sua aplicação está atualizada!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await authService.logout();
              if (success) {
                Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (route) => false
                );
              }
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}