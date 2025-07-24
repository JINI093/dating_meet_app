enum LogLevel { debug, info, warning, error }

class Logger {
  static void d(String msg) => _log(msg, LogLevel.debug);
  static void i(String msg) => _log(msg, LogLevel.info);
  static void w(String msg) => _log(msg, LogLevel.warning);
  static void e(String msg) => _log(msg, LogLevel.error);
  
  // 새로운 API 메서드들
  static void log(String msg, {String? name}) {
    final prefix = name != null ? '[$name]' : '';
    print('$prefix $msg');
  }
  
  static void error(String msg, {Object? error, String? name}) {
    log('[ERROR] $msg ${error != null ? '($error)' : ''}', name: name);
  }

  static void _log(String msg, LogLevel level) {
    final prefix = '[${level.name.toUpperCase()}]';
    // AWS/Flutter 구분은 prefix로 처리
    print('$prefix $msg');
  }
} 