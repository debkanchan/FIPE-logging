import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:loggy/loggy.dart';

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

    FirebaseCrashlytics.instance.log(record.toString());

    super.onLog(record);
  }
}
