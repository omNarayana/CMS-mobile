import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Required for debugPrint
import 'package:flutterapp/core/network/dio_client.dart';
import 'package:flutterapp/core/storage/secure_storage.dart'; // Ensure this path is correct
import 'package:flutterapp/models/student_profile.dart';

class ApiService {
  final Dio _dio = DioClient.dio;

  /// Fetches the current user's profile data
// lib/services/auth_service.dart

  Future<StudentProfile> getProfile() async {
    try {
      final response = await _dio.get('/v1/user/get-me');

      // Check your backend status flag
      if (response.data['status'] == true && response.data['data'] != null) {
        return StudentProfile.fromJson(response.data['data']);
      } else {
        // Throwing an exception triggers the .when(error: ...) block in Riverpod
        throw Exception(response.data['message'] ?? "Profile data is empty");
      }
    } catch (e) {
      rethrow;
    }
  }
  /// Logs out the user by notifying the backend and clearing local storage
  Future<void> logout() async {
    try {
      // Use the internal _dio instance which has your interceptors/SSL bypass
      await _dio.post('/v1/user/logout');
    } catch (e) {
      debugPrint('Server logout failed: $e');
    } finally {
      // ALWAYS clear the token locally, even if the network call fails
      await TokenStorage.removeToken();
    }
  }

  // --- Keep your existing GET, POST, PUT, DELETE methods below ---

  Future<Response> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      debugPrint("POST Error: ${e.response?.data}");
      rethrow;
    }
  }
}