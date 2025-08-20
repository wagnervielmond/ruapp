import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../data/models/aluno.dart';
import '../../data/models/acesso.dart';
import '../../data/repositories/user_repository.dart';
import '../../utils/logger.dart';

class UserProvider with ChangeNotifier {
  final UserRepository userRepository;
  final Logger _logger = getLogger('UserProvider');

  // Estados do usuário
  Aluno? _aluno;
  List<Acesso> _historicoAcessos = [];
  double _saldo = 0.0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserProvider({
    required this.userRepository,
  });

  // Getters
  Aluno? get aluno => _aluno;
  List<Acesso> get historicoAcessos => _historicoAcessos;
  double get saldo => _saldo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Atualizar estado de autenticação
  void updateAuthState(bool authenticated) {
    _isAuthenticated = authenticated;
    if (authenticated) {
      _loadUserData();
    } else {
      _clearUserData();
    }
  }

  // Carregar dados do usuário
  Future<void> _loadUserData() async {
    if (!_isAuthenticated) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Carregar dados em paralelo
      await Future.wait([
        _loadProfile(),
        _loadBalance(),
        _loadAccessHistory(),
      ]);

      _logger.i('User data loaded successfully');
    } catch (e) {
      _errorMessage = 'Erro ao carregar dados do usuário';
      _logger.e('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar perfil
  Future<void> _loadProfile() async {
    try {
      final aluno = await userRepository.getProfile();
      if (aluno != null) {
        _aluno = aluno;
        _logger.i('Profile loaded: ${aluno.nome}');
      }
    } catch (e) {
      _logger.e('Error loading profile: $e');
      rethrow;
    }
  }

  // Carregar saldo
  Future<void> _loadBalance() async {
    try {
      final balance = await userRepository.getBalance();
      _saldo = balance;
      _logger.i('Balance loaded: $balance');
    } catch (e) {
      _logger.e('Error loading balance: $e');
      rethrow;
    }
  }

  // Carregar histórico de acessos
  Future<void> _loadAccessHistory({int limit = 20, int offset = 0}) async {
    try {
      final historico = await userRepository.getAccessHistory(
        limit: limit,
        offset: offset,
      );
      _historicoAcessos = historico;
      _logger.i('Access history loaded: ${historico.length} items');
    } catch (e) {
      _logger.e('Error loading access history: $e');
      rethrow;
    }
  }

  // Atualizar saldo
  Future<bool> updateBalance(double newBalance) async {
    try {
      _saldo = newBalance;
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Error updating balance: $e');
      return false;
    }
  }

  // Recarregar saldo
  Future<bool> recarregarSaldo(double valor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await userRepository.rechargeBalance(valor);

      if (success) {
        // Atualizar saldo local
        _saldo += valor;
        _logger.i('Balance recharged: +$valor. New balance: $_saldo');
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Erro ao recarregar saldo';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão ao recarregar';
      _logger.e('Recharge error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Atualizar perfil
  Future<bool> atualizarPerfil(Map<String, dynamic> updates) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await userRepository.updateProfile(updates);

      if (success) {
        // Atualizar dados locais
        if (_aluno != null) {
          _aluno = Aluno(
            id: _aluno!.id,
            matricula: _aluno!.matricula,
            nome: updates['nome'] ?? _aluno!.nome,
            email: updates['email'] ?? _aluno!.email,
            urlFoto: updates['url_foto'] ?? _aluno!.urlFoto,
            saldo: _aluno!.saldo,
          );
        }

        _logger.i('Profile updated successfully');
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Erro ao atualizar perfil';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão ao atualizar';
      _logger.e('Profile update error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Alterar senha
  Future<bool> alterarSenha(String senhaAtual, String novaSenha) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await userRepository.changePassword(senhaAtual, novaSenha);

      if (success) {
        _logger.i('Password changed successfully');
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Erro ao alterar senha';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão ao alterar senha';
      _logger.e('Password change error: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Carregar mais histórico
  Future<void> carregarMaisHistorico() async {
    try {
      final maisHistorico = await userRepository.getAccessHistory(
        limit: 20,
        offset: _historicoAcessos.length,
      );

      _historicoAcessos.addAll(maisHistorico);
      _logger.i('Loaded more history: ${maisHistorico.length} items');
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading more history: $e');
    }
  }

  // Atualizar dados do usuário
  Future<void> refreshUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadProfile(),
        _loadBalance(),
      ]);

      _logger.i('User data refreshed');
    } catch (e) {
      _errorMessage = 'Erro ao atualizar dados';
      _logger.e('Refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpar dados do usuário
  void _clearUserData() {
    _aluno = null;
    _historicoAcessos = [];
    _saldo = 0.0;
    _errorMessage = null;
    _logger.i('User data cleared');
    notifyListeners();
  }

  // Limpar erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Verificar se tem histórico
  bool get hasHistory => _historicoAcessos.isNotEmpty;

  // Obter últimos acessos
  List<Acesso> get ultimosAcessos {
    return _historicoAcessos.take(5).toList();
  }

  // Obter total gasto no mês
  double get totalGastoMes {
    final now = DateTime.now();
    return _historicoAcessos
        .where((acesso) =>
    acesso.dataHora.month == now.month &&
        acesso.dataHora.year == now.year)
        .fold(0.0, (sum, acesso) => sum + acesso.custo);
  }

  // Estatísticas de uso
  Map<String, dynamic> get estatisticas {
    final now = DateTime.now();
    final acessosMes = _historicoAcessos.where((acesso) =>
    acesso.dataHora.month == now.month &&
        acesso.dataHora.year == now.year);

    return {
      'total_acessos_mes': acessosMes.length,
      'total_gasto_mes': acessosMes.fold(0.0, (sum, acesso) => sum + acesso.custo),
      'media_diaria': acessosMes.length / now.day,
    };
  }

  // Disposer
  @override
  void dispose() {
    _logger.i('UserProvider disposed');
    super.dispose();
  }
}