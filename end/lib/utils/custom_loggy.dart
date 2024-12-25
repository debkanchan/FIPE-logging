import 'package:loggy/loggy.dart';

// LogLevel is just a class with `name` and `priority`. Priority can go from 1 - 99 inclusive.
const LogLevel socketLevel = LogLevel('trace', 1);

extension TraceLoggy on Loggy {
  void rrace(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      log(socketLevel, message, error, stackTrace);
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
