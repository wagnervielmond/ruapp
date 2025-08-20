import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final aluno = authService.aluno;

    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Perfil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(Constants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: aluno?.urlFoto != null
                    ? NetworkImage(aluno!.urlFoto!)
                    : AssetImage('assets/images/default_avatar.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 24),
            _buildInfoItem('Nome', aluno?.nome ?? ''),
            _buildInfoItem('Matrícula', aluno?.matricula ?? ''),
            _buildInfoItem('Email', aluno?.email ?? ''),
            _buildInfoItem('Saldo', Helpers.formatCurrency(aluno?.saldo ?? 0)),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navegar para tela de recarga
              },
              child: Text('Recarregar Saldo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}