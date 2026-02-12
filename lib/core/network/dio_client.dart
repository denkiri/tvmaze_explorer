import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// Provides a configured Dio instance for TVMaze API communication.
// Timeouts: 5s connect, 15s receive.
// Includes logging interceptor in debug mode.
class DioClient {
  DioClient() : _dio = Dio(_baseOptions) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  final Dio _dio;

  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: 'https://api.tvmaze.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Accept': 'application/json',
    },
  );

  Dio get dio => _dio;
}
