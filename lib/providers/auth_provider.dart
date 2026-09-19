// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../core/storage/secure_storage.dart';
import '../models/student_profile.dart';


// FIX: Define apiServiceProvider consistently
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Global session monitoring token provider watched by main.dart
final authProvider = FutureProvider<String?>((ref) async {
  return await TokenStorage.getToken();
});

// Updated to use StudentProfile model
// lib/providers/auth_provider.dart

final profileProvider = FutureProvider.autoDispose<StudentProfile>((ref) async {
  // 1. Watch auth state. If this changes, profileProvider resets.
  final authState = ref.watch(authProvider);
  final token = authState.value;

  if (token == null || token.isEmpty) {
    throw Exception("User is not authenticated");
  }

  // 2. Use ref.watch for the service to ensure consistency
  final apiService = ref.watch(apiServiceProvider);

  return await apiService.getProfile();
});
// Controller for handling side effects like Logout
final authControllerProvider = StateNotifierProvider<AuthController, void>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<void> {
  final Ref ref;
  AuthController(this.ref) : super(null);

  Future<void> handleLogout() async {
    try {
      await ref.read(apiServiceProvider).logout();
    } finally {
      // Clear BOTH tokens on logout
      await TokenStorage.removeToken();
      await TokenStorage.removeRefreshToken(); // Added this line

      // Trigger automatic UI redirect to Login Screen
      ref.invalidate(authProvider);
    }
  }
}