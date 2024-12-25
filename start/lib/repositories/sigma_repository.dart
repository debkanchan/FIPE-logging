import 'dart:io';
import 'dart:convert';

import 'package:sigma_detector/sources/sigma_api.dart';

class SigmaRepository {
  final SigmaApi _api = SigmaApi();

  Future<bool> isSigma(String uid, File image) async {
    // Fetch data from API

    List<int> imageBytes = image.readAsBytesSync();
    print(imageBytes);
    String encodedImage = base64Encode(imageBytes);

    return _api.getSigmaData(uid, encodedImage);
  }
}
