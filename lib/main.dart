import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ruapp/presentation/providers/auth_provider.dart';
import 'package:ruapp/presentation/providers/qr_provider.dart';
import 'package:ruapp/presentation/providers/theme_provider.dart';
import 'package:ruapp/presentation/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/qr_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar serviços
  await SharedPreferences.getInstance();
  final storageService = StorageService();
  await storageService.init();

  final apiService = ApiService();
  final authRepository = AuthRepository(apiService, storageService);
  final qrRepository = QrRepository(apiService, storageService: storageService);
  final userRepository = UserRepository(apiService); // UserRepository não precisa de storageService

  runApp(MyApp(
    authRepository: authRepository,
    qrRepository: qrRepository,
    userRepository: userRepository,
    storageService: storageService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final QrRepository qrRepository;
  final UserRepository userRepository;
  final StorageService storageService;

  const MyApp({
    required this.authRepository,
    required this.qrRepository,
    required this.userRepository,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => QrProvider(qrRepository: qrRepository),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(
            userRepository: userRepository, // CORREÇÃO: Removido storageService
          ),
          update: (_, authProvider, userProvider) {
            userProvider?.updateAuthState(authProvider.isAuthenticated);
            return userProvider!;
          },
        ),
      ],
      child: App(),
    );
  }
}