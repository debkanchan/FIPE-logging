import 'dart:io';
import 'dart:convert';

import 'package:sigma_detector/sources/sigma_api.dart';
import 'package:sigma_detector/utils/custom_loggy.dart';

class SigmaRepository with RepositoryLoggy {
  final SigmaApi _api = SigmaApi();

  Future<bool> isSigma(String uid, File image) async {
    // Fetch data from API

    List<int> imageBytes = image.readAsBytesSync();
    String encodedImage = base64Encode(imageBytes);
    loggy.debug("Encoded image: $encodedImage");

    try {
      return _api.getSigmaData(uid, encodedImage);
    } catch (e) {
      loggy.error("Error fetching data from API", e);
      return false;
    }
  }
}
