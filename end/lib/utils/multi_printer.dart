import 'package:loggy/loggy.dart';

class MultiPrinter extends LoggyPrinter {
  final Set<LoggyPrinter> printers;

  const MultiPrinter(this.printers) : super();

  @override
  void onLog(LogRecord record) {
    for (var printer in printers) {
      printer.onLog(record);
    }
  }
}
