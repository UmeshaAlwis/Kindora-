import 'package:dio/dio.dart';

/// Dio instance for Kindora backend calls.
///
/// Explicit timeouts avoid Dio 5.x treating a zero duration as "instant fail"
/// on some platforms, and give the server time to respond on slow networks.
Dio createApiDio() {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
      },
    ),
  );
}
