import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  // Storage Keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token'; // 1. Added refresh token key

  // --- Existing Access Token Methods ---
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  // --- ADD THESE NEW METHODS FOR REFRESH TOKEN ---

  /// Fetches the stored refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Saves the refresh token during login
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Clears the refresh token during logout
  static Future<void> removeRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }
}