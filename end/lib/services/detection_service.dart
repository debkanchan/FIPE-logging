import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sigma_detector/repositories/sigma_repository.dart';
import 'package:sigma_detector/utils/custom_loggy.dart';
import 'package:sigma_detector/utils/log_extension.dart';

import 'package:uuid/uuid.dart';

class DetectionService with ServiceLoggy {
  final _repo = SigmaRepository();

  Future<bool> analyse(File image) async {
    final uuid = Uuid().v4();

    loggy.debug("uuid: $uuid");

    if (DateTime.now().millisecond % 100 < 50) {
      FirebaseCrashlytics.instance.crash();
    }

    loggy.trace("Request started at ${DateTime.now()}");
    final result = _repo.isSigma(uuid, image);
    loggy.trace("Request complete at ${DateTime.now()}");

    return result;
  }
}
