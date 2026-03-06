import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authentication token if needed
          // const token = await StorageService.getToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          debugPrint('API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          debugPrint('API Error: ${error.message}');
          return handler.next(error);
        },
        onResponse: (response, handler) {
          debugPrint('API Response: ${response.statusCode}');
          return handler.next(response);
        },
      ),
    );
  }

  Future<Response> post(String endpoint, {required Map<String, dynamic> data}) {
    return _dio.post(endpoint, data: data);
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) {
    return _dio.get(endpoint, queryParameters: params);
  }

  Future<Response> put(String endpoint, {required Map<String, dynamic> data}) {
    return _dio.put(endpoint, data: data);
  }

  Future<Response> delete(String endpoint) {
    return _dio.delete(endpoint);
  }
}

// Singleton instance
final apiClient = ApiClient();
