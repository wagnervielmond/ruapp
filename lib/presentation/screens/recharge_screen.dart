import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../../utils/helpers.dart';
import '../themes/colors.dart';
import '../themes/text_styles.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_overlay.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  _RechargeScreenState createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  String _metodoSelecionado = 'pix';
  bool _isLoading = false;

  // Valores pré-definidos para recarga
  final List<double> _valoresRapidos = [10.00, 20.00, 50.00, 100.00];
  final Map<String, String> _metodosPagamento = {
    'pix': 'PIX',
    'credit_card': 'Cartão de Crédito',
    'debit_card': 'Cartão de Débito',
    'boleto': 'Boleto Bancário',
  };

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _realizarRecarga() async {
    if (!_formKey.currentState!.validate()) return;

    final valor = double.parse(_valorController.text);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      final sucesso = await userProvider.recarregarSaldo(valor);

      if (sucesso && mounted) {
        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recarga de ${Helpers.formatCurrency(valor)} realizada com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Voltar para tela anterior
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            message: 'Erro ao realizar recarga: $e',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selecionarValorRapido(double valor) {
    _valorController.text = valor.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recarregar Saldo'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saldo Atual
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Saldo Atual:',
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            Helpers.formatCurrency(userProvider.saldo),
                            style: AppTextStyles.balanceLarge,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Valor da Recarga
                  Text(
                    'Valor da Recarga',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _valorController,
                    decoration: const InputDecoration(
                      prefixText: 'R\$ ',
                      hintText: '0,00',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o valor da recarga';
                      }
                      final valor = double.tryParse(value);
                      if (valor == null || valor <= 0) {
                        return 'Valor deve ser maior que zero';
                      }
                      if (valor > 1000) {
                        return 'Valor máximo é R\$ 1.000,00';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Valores Rápidos
                  Text(
                    'Valores Rápidos',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _valoresRapidos.map((valor) {
                      return ChoiceChip(
                        label: Text(Helpers.formatCurrency(valor)),
                        selected: _valorController.text == valor.toStringAsFixed(2),
                        onSelected: (_) => _selecionarValorRapido(valor),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Método de Pagamento
                  Text(
                    'Método de Pagamento',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _metodoSelecionado,
                    items: _metodosPagamento.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _metodoSelecionado = value!);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botão de Recarregar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _realizarRecarga,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                          : Text(
                        'Recarregar',
                        style: AppTextStyles.buttonLarge,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Informações adicionais
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Informações:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('• Recargas via PIX são instantâneas'),
                          Text('• Cartões podem levar até 2 minutos'),
                          Text('• Boletos levam 1-2 dias úteis'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}