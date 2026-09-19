import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart'; // Verify this path matches your project layout

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final responseData = err.response?.data;

    debugPrint('--- [AUTH] 401 Response ---');
    debugPrint('Data: $responseData');
    debugPrint('Data Type: ${responseData.runtimeType}');

    // Safely extract the error code
    String? errorCode;

    if (responseData is Map) {
      errorCode = responseData['code']?.toString();
    }

    debugPrint('Error Code: $errorCode');

    if (errorCode != 'TOKEN_EXPIRED') {
      return handler.next(err);
    }

    // Prevent retry loops
    if (err.requestOptions.extra['isRetry'] == true) {
      debugPrint('--- [AUTH] Request already retried. Giving up. ---');

      await TokenStorage.removeToken();
      return handler.next(err);
    }

    debugPrint(
      '--- [AUTH] Access Token Expired. Attempting silent renewal... ---',
    );

    try {
      // 1. Refresh the token
      final newAccessToken = await _handleTokenRefresh(
        err.requestOptions.baseUrl,
      );

      if (newAccessToken == null) {
        debugPrint('--- [AUTH] Token refresh returned null ---');

        await TokenStorage.removeToken();
        return handler.next(err);
      }

      debugPrint(
        '--- [AUTH] Token renewed successfully. Retrying request... ---',
      );

      // 2. Create new request options
      final requestOptions = err.requestOptions.copyWith(
        headers: {
          ...err.requestOptions.headers,
          'Authorization': 'Bearer $newAccessToken',
        },
        extra: {
          ...err.requestOptions.extra,
          'isRetry': true,
        },
      );

      // 3. Use a separate Dio instance for retry
      final retryDio = Dio(
        BaseOptions(
          baseUrl: requestOptions.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // SSL configuration
      retryDio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();

          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
            return true;
          };

          return client;
        },
      );

      // 4. Retry original request
      final retryResponse = await retryDio.fetch(requestOptions);

      debugPrint(
        '--- [AUTH] Retry successful: ${retryResponse.statusCode} ---',
      );

      return handler.resolve(retryResponse);
    } catch (refreshError, stackTrace) {
      debugPrint(
        '--- [AUTH] Token renewal failed: $refreshError ---',
      );

      debugPrint(stackTrace.toString());

      await TokenStorage.removeToken();

      return handler.next(err);
    }
  }

  /// Private helper to request a fresh Access Token using the stored Refresh Token
  Future<String?> _handleTokenRefresh(String baseUrl) async {
    // Ensure you have logic in TokenStorage to manage the refresh token key
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception("No refresh token found in secure storage");
    }

    final refreshDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
    ));

    // Apply local dev SSL bypass
    refreshDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );

    // Call your backend's token token renewal endpoint
    final response = await refreshDio.post(
      '/v1/user/refresh-token', // Double check if your endpoint matches this route
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200 && response.data['status'] == true) {
      final newAccessToken = response.data['data']['accessToken']?.toString();

      if (newAccessToken != null) {
        // Save the new token back to persistent device storage
        await TokenStorage.saveToken(newAccessToken);
        return newAccessToken;
      }
    }

    return null;
  }
}