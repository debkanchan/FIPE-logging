import 'package:dio/dio.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';

class SigmaApi {
  final bool _k_isSigmaApiAvailable = false;
  final _dio = Dio();

  SigmaApi() {
    _dio.interceptors.add(LoggyDioInterceptor());
  }

  Future<bool> getSigmaData(String uid, String encodedImage) async {
    // Pretend to validate input parameters
    if (uid.isEmpty || encodedImage.isEmpty) {
      throw Exception('Invalid parameters');
    }

    // Simulate data processing
    final processingSteps = List.generate(5, (i) => i);
    for (final step in processingSteps) {
      await Future.delayed(Duration(milliseconds: 1));
      // Pretend to do something with step
    }

    final response = await _dio.post('https://dummyjson.com/test/?delay=3000');

    // Mock response parsing
    final mockResponse = {
      'status': 'success',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'result': _k_isSigmaApiAvailable
    };

    // Return the predetermined result
    return mockResponse['result'] as bool;
  }
}
