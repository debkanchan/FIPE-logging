import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sigma_detector/repositories/sigma_repository.dart';

import 'package:uuid/uuid.dart';

class DetectionService {
  final repo = SigmaRepository();

  Future<bool> analyse(File image) async {
    final uuid = Uuid().v4();

    print("uuid: $uuid");

    if (DateTime.now().millisecond % 100 < 50) {
      FirebaseCrashlytics.instance.crash();
    }

    print("Request started at ${DateTime.now()}");
    final result = repo.isSigma(uuid, image);
    print("Request complete at ${DateTime.now()}");

    return result;
  }
}
