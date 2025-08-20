import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/qr_provider.dart';
import '../themes/colors.dart';
import '../widgets/qr_code_widget.dart';
import './profile_screen.dart';
import './history_screen.dart';
import './recharge_screen.dart';
import './config_screen.dart';
import '../../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Gerar QR automaticamente ao abrir a tela (opcional)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final qrProvider = Provider.of<QrProvider>(context, listen: false);
      if (qrProvider.canGenerateNewQr) {
        _generateQrCode();
      }
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
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final qrProvider = Provider.of<QrProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('RU-APP'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (qrProvider.currentQrToken != null && qrProvider.isQrValid)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: qrProvider.canGenerateNewQr ? _generateQrCode : null,
              tooltip: 'Gerar novo QR Code',
            ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context, authProvider),
            tooltip: 'Sair',
          ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider, userProvider.aluno),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de boas-vindas (mantido da versão original)
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: userProvider.aluno?.urlFoto != null
                          ? NetworkImage(userProvider.aluno!.urlFoto!)
                          : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Olá, ${userProvider.aluno?.nome ?? ''}',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      userProvider.aluno?.matricula ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Saldo',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              Helpers.formatCurrency(userProvider.aluno?.saldo ?? 0),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Status',
                              style: theme.textTheme.bodySmall,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Ativo',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Seção do QR Code (adaptada da nova versão)
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
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrCodeWidget(
                        data: qrProvider.currentQrToken!,
                        size: 200,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Timer
                    Text(
                      'Válido por: ${qrProvider.formattedTimeRemaining}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),

              // Botão de ação
              ElevatedButton(
                onPressed: qrProvider.canGenerateNewQr ? _generateQrCode : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Gerar Novo QR Code'),
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

              ElevatedButton(
                onPressed: _generateQrCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Gerar QR Code'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider, dynamic aluno) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Header do Drawer com informações do usuário
          UserAccountsDrawerHeader(
            accountName: Text(
              aluno?.nome ?? 'Usuário',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              aluno?.email ?? aluno?.matricula ?? '',
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.primaryColor,
              backgroundImage: aluno?.urlFoto != null
                  ? NetworkImage(aluno!.urlFoto!)
                  : null,
              child: aluno?.urlFoto == null
                  ? Text(
                aluno?.nome?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(fontSize: 20, color: Colors.white),
              )
                  : null,
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
          ),

          // Itens do menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Início',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'Meu Perfil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: 'Recarregar Saldo',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RechargeScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.history,
                  title: 'Histórico de Refeições',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.qr_code,
                  title: 'Gerar QR Code',
                  onTap: () {
                    Navigator.pop(context);
                    _generateQrCode();
                  },
                ),
                Divider(),

                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Configurações',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConfigScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help,
                  title: 'Ajuda e Suporte',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
                Divider(),

                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Sair',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutConfirmation(context, authProvider);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        Color? color,
      }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Como usar o QR Code'),
        content: Text(
          'Para dúvidas, problemas ou sugestões, entre em contato conosco:\n\n'
              'Email: suporte-ru@universidade.edu.br\n'
              'Telefone: (XX) XXXX-XXXX\n\n'
              'Horário de atendimento:\n'
              'Segunda a sexta, das 8h às 18h',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sair da Conta'),
        content: Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
            },
            child: Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/user_provider.dart';
// import '../providers/auth_provider.dart';
// import '../themes/colors.dart';
// import './qr_generator_screen.dart';
// import './profile_screen.dart';
// import './history_screen.dart';
// import './recharge_screen.dart';
// import '../../utils/helpers.dart';
//
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);
//     final authProvider = Provider.of<AuthProvider>(context);
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('RU-APP'),
//         backgroundColor: theme.primaryColor,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.exit_to_app),
//             onPressed: () => authProvider.logout(),
//             tooltip: 'Sair',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Card de boas-vindas
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundImage: userProvider.aluno?.urlFoto != null
//                           ? NetworkImage(userProvider.aluno!.urlFoto!)
//                           : AssetImage('assets/images/default_avatar.png') as ImageProvider,
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'Olá, ${userProvider.aluno?.nome ?? ''}',
//                       style: theme.textTheme.titleLarge,
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       userProvider.aluno?.matricula ?? '',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: theme.disabledColor,
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         Column(
//                           children: [
//                             Text(
//                               'Saldo',
//                               style: theme.textTheme.bodySmall,
//                             ),
//                             Text(
//                               Helpers.formatCurrency(userProvider.aluno?.saldo ?? 0),
//                               style: theme.textTheme.titleLarge?.copyWith(
//                                 color: AppColors.primary,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Column(
//                           children: [
//                             Text(
//                               'Status',
//                               style: theme.textTheme.bodySmall,
//                             ),
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: AppColors.success.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 'Ativo',
//                                 style: theme.textTheme.bodySmall?.copyWith(
//                                   color: AppColors.success,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 24),
//
//             // Botão principal - Gerar QR Code
//             ElevatedButton.icon(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => QrGeneratorScreen()),
//               ),
//               icon: Icon(Icons.qr_code_2, size: 24),
//               label: Text(
//                 'Gerar QR Code para o RU',
//                 style: theme.textTheme.titleMedium,
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(vertical: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 16),
//
//             // Grid de ações
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               children: [
//                 _buildActionButton(
//                   context,
//                   icon: Icons.history,
//                   label: 'Histórico',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => HistoryScreen()),
//                   ),
//                 ),
//                 _buildActionButton(
//                   context,
//                   icon: Icons.account_balance_wallet,
//                   label: 'Recarregar',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => RechargeScreen()),
//                   ),
//                 ),
//                 _buildActionButton(
//                   context,
//                   icon: Icons.person,
//                   label: 'Perfil',
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ProfileScreen()),
//                   ),
//                 ),
//                 _buildActionButton(
//                   context,
//                   icon: Icons.help,
//                   label: 'Ajuda',
//                   onTap: () => _showHelpDialog(context),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButton(
//       BuildContext context, {
//         required IconData icon,
//         required String label,
//         required VoidCallback onTap,
//       }) {
//     return Card(
//       elevation: 2,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 32, color: AppColors.primary),
//               SizedBox(height: 8),
//               Text(
//                 label,
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showHelpDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Como usar o QR Code'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('1. Toque em "Gerar QR Code para o RU"'),
//             Text('2. Mostre o QR Code para o atendente'),
//             Text('3. O atendente escaneia o código'),
//             Text('4. Acesso liberado automaticamente'),
//             SizedBox(height: 16),
//             Text(
//               'O QR Code expira em 30 segundos por segurança.',
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Entendi'),
//           ),
//         ],
//       ),
//     );
//   }
// }