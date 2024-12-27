import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:loggy/loggy.dart';
import 'custom_loggy.dart';

class CrashlyticsPrinter extends PrettyPrinter {
  const CrashlyticsPrinter() : super();

  @override
  void onLog(LogRecord record) {
    if (record.level == LogLevel.error) {
      FirebaseCrashlytics.instance.recordError(
        record.message,
        record.stackTrace,
        reason: record.error,
      );
    }

    if (record.level == fatalLevel) {
      FirebaseCrashlytics.instance.recordError(
        record.message,
        record.stackTrace,
        reason: record.error,
        fatal: true,
      );
    }

    FirebaseCrashlytics.instance.log(record.toString());

    super.onLog(record);
  }
}
