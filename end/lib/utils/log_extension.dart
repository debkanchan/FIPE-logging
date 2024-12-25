import 'package:loggy/loggy.dart';

// LogLevel is just a class with `name` and `priority`. Priority can go from 1 - 99 inclusive.
const LogLevel traceLevel = LogLevel('trace', 1);

extension TraceLoggy on Loggy {
  void trace(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      log(traceLevel, message, error, stackTrace);
}
