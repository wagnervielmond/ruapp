import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart' as logger_lib;
import 'package:flutter/foundation.dart';

// Níveis de log personalizados
enum LogLevel {
  verbose(0, 'VERBOSE'),
  debug(1, 'DEBUG'),
  info(2, 'INFO'),
  warning(3, 'WARNING'),
  error(4, 'ERROR'),
  wtf(5, 'WTF');

  final int value;
  final String name;
  const LogLevel(this.value, this.name);
}

// Filtro personalizado para logs
class CustomLogFilter extends logger_lib.LogFilter {
  final LogLevel minLevel;

  CustomLogFilter({this.minLevel = LogLevel.debug});

  @override
  bool shouldLog(logger_lib.LogEvent event) {
    return event.level.value >= minLevel.value;
  }
}

// Formatador personalizado para logs
class CustomLogFormatter {
  final bool showTime;
  final bool showLevel;
  final bool showEmojis;

  CustomLogFormatter({
    this.showTime = true,
    this.showLevel = true,
    this.showEmojis = true,
  });

  @override
  String format(logger_lib.LogEvent event) {
    final buffer = StringBuffer();

    // Adicionar hora se habilitado
    if (showTime) {
      final now = DateTime.now();
      buffer.write('${_formatTime(now)} ');
    }

    // Adicionar nível do log com emoji se habilitado
    if (showLevel) {
      final level = _getLogLevel(event.level);
      if (showEmojis) {
        buffer.write('${_getLevelEmoji(level)} ');
      }
      buffer.write('${level.name} ');
    }

    // Adicionar mensagem
    buffer.write(event.message);

    // Adicionar erro se existir
    if (event.error != null) {
      buffer.write(' | Error: ${event.error}');
    }

    // Adicionar stack trace se existir
    if (event.stackTrace != null) {
      buffer.write(' | Stack: ${event.stackTrace}');
    }

    return buffer.toString();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }

  LogLevel _getLogLevel(logger_lib.Level level) {
    switch (level) {
      case logger_lib.Level.verbose:
        return LogLevel.verbose;
      case logger_lib.Level.debug:
        return LogLevel.debug;
      case logger_lib.Level.info:
        return LogLevel.info;
      case logger_lib.Level.warning:
        return LogLevel.warning;
      case logger_lib.Level.error:
        return LogLevel.error;
      case logger_lib.Level.wtf:
        return LogLevel.wtf;
      default:
        return LogLevel.debug;
    }
  }

  String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return '🔍';
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.wtf:
        return '🤯';
      default:
        return '📝';
    }
  }
}

// Output personalizado para logs
class CustomLogOutput extends logger_lib.LogOutput {
  final bool printToConsole;
  final List<String> _logBuffer = [];

  CustomLogOutput({this.printToConsole = true});

  @override
  void output(logger_lib.OutputEvent event) {
    for (var line in event.lines) {
      if (printToConsole) {
        // Usar debugPrint para melhor performance em modo debug
        debugPrint(line);
      }

      // Manter buffer limitado para possível uso futuro
      _logBuffer.add(line);
      if (_logBuffer.length > 1000) {
        _logBuffer.removeAt(0);
      }
    }
  }

  List<String> getLogs() => List.from(_logBuffer);

  void clearLogs() => _logBuffer.clear();
}

// Gerenciador central de logging
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final Map<String, logger_lib.Logger> _loggers = {};
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  logger_lib.Logger getLogger(String name) {
    if (!_loggers.containsKey(name)) {
      _loggers[name] = logger_lib.Logger(
        filter: CustomLogFilter(minLevel: _minLevel),
        printer: logger_lib.PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          lineLength: 80,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
        output: CustomLogOutput(printToConsole: true),
      );
    }
    return _loggers[name]!;
  }

  void setMinLevel(LogLevel level) {
    _minLevel = level;
    // Atualizar filtro de todos os loggers existentes
    for (var logger in _loggers.values) {
      // Não é possível alterar o filtro diretamente, então recriamos os loggers
      _loggers.clear();
    }
  }

  LogLevel getMinLevel() => _minLevel;

  void disableLogging() {
    setMinLevel(LogLevel.wtf); // Apenas logs críticos
  }

  void enableDebugLogging() {
    setMinLevel(LogLevel.debug);
  }

  void enableVerboseLogging() {
    setMinLevel(LogLevel.verbose);
  }

  // Métodos de log rápidos usando os métodos corretos do pacote logger
  static void v(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _getLogger(tag).t(message, error: error, stackTrace: stackTrace);
  }

  static void d(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _getLogger(tag).d(message, error: error, stackTrace: stackTrace);
  }

  static void i(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _getLogger(tag).i(message, error: error, stackTrace: stackTrace);
  }

  static void w(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _getLogger(tag).w(message, error: error, stackTrace: stackTrace);
  }

  static void e(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _getLogger(tag).e(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _getLogger(tag).wtf(message, error: error, stackTrace: stackTrace);
  }

  static logger_lib.Logger _getLogger(String? tag) {
    return AppLogger().getLogger(tag ?? 'App');
  }
}

// Função de conveniência para obter logger
logger_lib.Logger getLogger(String name) {
  return AppLogger().getLogger(name);
}

// Extensões para Logger original com os nomes de métodos corretos
extension LoggerExtensions on logger_lib.Logger {
  void log(LogLevel level, String message, {dynamic error, StackTrace? stackTrace}) {
    switch (level) {
      case LogLevel.verbose:
        t(message, error: error, stackTrace: stackTrace); // t() é para verbose
        break;
      case LogLevel.debug:
        d(message, error: error, stackTrace: stackTrace); // d() é para debug
        break;
      case LogLevel.info:
        i(message, error: error, stackTrace: stackTrace); // i() é para info
        break;
      case LogLevel.warning:
        w(message, error: error, stackTrace: stackTrace); // w() é para warning
        break;
      case LogLevel.error:
        e(message, error: error, stackTrace: stackTrace); // e() é para error
        break;
      case LogLevel.wtf:
        wtf(message, error: error, stackTrace: stackTrace); // wtf() é para wtf
        break;
    }
  }
}

// Mixin para adicionar logging a classes
mixin Loggable {
  logger_lib.Logger get _logger => getLogger(runtimeType.toString());

  void logV(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace); // t() para verbose
  }

  void logD(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace); // d() para debug
  }

  void logI(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace); // i() para info
  }

  void logW(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace); // w() para warning
  }

  void logE(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace); // e() para error
  }

  void logWtf(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.wtf(message, error: error, stackTrace: stackTrace); // wtf() para wtf
  }
}

// Interceptor para logging de navegação
class NavigationObserver with Loggable implements NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    logI('Navigator pushed: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    logI('Navigator popped: ${route.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    logI('Navigator removed: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    logI('Navigator replaced: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    logD('User gesture started on: ${route.settings.name}');
  }

  @override
  void didStopUserGesture() {
    logD('User gesture stopped');
  }

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    // TODO: implement didChangeTop
  }

  @override
  // TODO: implement navigator
  NavigatorState? get navigator => throw UnimplementedError();
}

// Utilitário para logging de performance
class PerformanceLogger {
  final Map<String, DateTime> _timers = {};
  final logger_lib.Logger _logger = getLogger('Performance');

  void startTimer(String name) {
    _timers[name] = DateTime.now();
  }

  void stopTimer(String name, {String? message}) {
    final startTime = _timers[name];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _logger.i('${message ?? name} took: ${duration.inMilliseconds}ms');
      _timers.remove(name);
    }
  }

  T measure<T>(String name, T Function() function, {String? message}) {
    startTimer(name);
    try {
      return function();
    } finally {
      stopTimer(name, message: message);
    }
  }

  Future<T> measureAsync<T>(String name, Future<T> Function() function, {String? message}) async {
    startTimer(name);
    try {
      return await function();
    } finally {
      stopTimer(name, message: message);
    }
  }
}

// Singleton global de performance logger
final performanceLogger = PerformanceLogger();