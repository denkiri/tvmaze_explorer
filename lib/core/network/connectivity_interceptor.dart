import 'dart:io';

import 'package:dio/dio.dart';

// Interceptor that performs a quick DNS lookup before each request.
// If the device has no internet, this fails almost instantly (~100ms)
// instead of waiting for the full connectTimeout (5s).
class ConnectivityInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Quick DNS lookup — fails almost instantly when offline.
      final result = await InternetAddress.lookup('api.tvmaze.com')
          .timeout(const Duration(seconds: 2));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            message: 'No internet connection',
          ),
        );
      }
      handler.next(options);
    } catch (_) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
      );
    }
  }
}
