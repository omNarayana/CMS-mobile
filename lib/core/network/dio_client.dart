import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'api_interceptors.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        // baseUrl: "https://192.168.31.63:5005",
        baseUrl: "https://overabusive-trista-transdiaphragmatic.ngrok-free.dev",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    // Add Interceptors
    dio.interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
      ApiInterceptors(), // This refers to the class in api_interceptors.dart
    ]);
    // Add Interceptor

    // Add a manual print to verify initialization
    debugPrint("--- [NETWORK] DioClient Initialized for: ${dio.options.baseUrl} ---");
    // Handle self-signed certificates for local development
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    return dio;
  }
}