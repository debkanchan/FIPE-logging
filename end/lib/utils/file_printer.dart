import 'dart:convert';
import 'dart:io';

import 'package:loggy/loggy.dart';
import 'package:path_provider/path_provider.dart';

class FilePrinter extends PrettyPrinter {
  late final File file;
  IOSink? _sink;

  FilePrinter() : super() {
    getApplicationDocumentsDirectory().then((dir) {
      file = File('${dir.path}/log.txt');

      file.create(recursive: true);
      _sink = file.openWrite(
        mode: FileMode.writeOnly,
        encoding: utf8,
      );
    });
  }

  @override
  void onLog(LogRecord record) {
    _sink?.writeln(record.toString());
    super.onLog(record);
  }
}
