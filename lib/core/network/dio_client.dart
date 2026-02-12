import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tvmaze_explorer/core/network/connectivity_interceptor.dart';

//Provides a configured Dio instance for TVMaze API communication.
// Timeouts: 5s connect, 15s receive
// Includes connectivity check interceptor and logging interceptor in debug mode.
class DioClient {
  DioClient() : _dio = Dio(_baseOptions) {
    // Fast no-internet detection — fails in ~100ms when offline.
    _dio.interceptors.add(ConnectivityInterceptor());

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
