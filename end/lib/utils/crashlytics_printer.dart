import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:loggy/loggy.dart';

class CrashlyticsPrinter extends PrettyPrinter {
  const CrashlyticsPrinter() : super();

  @override
  void onLog(LogRecord record) {
    FirebaseCrashlytics.instance.log(record.toString());

    super.onLog(record);
  }
}
