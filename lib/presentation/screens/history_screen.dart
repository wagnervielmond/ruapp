import 'package:flutter/material.dart';
import '../../data/models/acesso.dart';
import '../../data/services/api_service.dart';
import '../../utils/helpers.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<Acesso> _acessos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistorico();
  }

  Future<void> _loadHistorico() async {
    try {
      final acessos = await _apiService.obterHistoricoAcessos(authToken: '');
      setState(() {
        _acessos = acessos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Acessos'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _acessos.isEmpty
          ? Center(
        child: Text(
          'Nenhum acesso registrado',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _acessos.length,
        itemBuilder: (context, index) {
          final acesso = _acessos[index];
          return _buildAcessoItem(acesso);
        },
      ),
    );
  }

  Widget _buildAcessoItem(Acesso acesso) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          acesso.status == 'sucesso' ? Icons.check_circle : Icons.error,
          color: acesso.status == 'sucesso' ? Colors.green : Colors.red,
        ),
        title: Text(Helpers.formatDate(acesso.dataHora)),
        subtitle: Text('${acesso.turnoRefeicao ?? 'Turno não especificado'}'),
        trailing: Text(
          Helpers.formatCurrency(acesso.custo),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: acesso.status == 'sucesso' ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}