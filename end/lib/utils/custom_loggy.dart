import 'package:loggy/loggy.dart';

// LogLevel is just a class with `name` and `priority`. Priority can go from 1 - 99 inclusive.
const LogLevel traceLevel = LogLevel('trace', 1);
const LogLevel fatalLevel = LogLevel('fatal', 99);

extension TraceLoggy on Loggy {
  void trace(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      log(traceLevel, message, error, stackTrace);
}

extension FatalLoggy on Loggy {
  void fatal(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      log(traceLevel, message, error, stackTrace);
}

mixin ServiceLoggy implements LoggyType {
  @override
  get loggy => Loggy<ServiceLoggy>('Service Loggy - ${runtimeType.toString()}');
}

mixin RepositoryLoggy implements LoggyType {
  @override
  get loggy =>
      Loggy<RepositoryLoggy>('Repository Loggy - ${runtimeType.toString()}');
}
