import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart'; // To access your ApiService or auth state
import '../services/academic_service.dart';
import '../models/academic_model.dart'; // Ensure this model exists
//
// final academicDataProvider = FutureProvider<AcademicDashboardData>((ref) async {
//   // 1. Get your API service/controller that contains the fetchAcademicData method
//   // Replace 'authControllerProvider' with the actual name of your logic class
//   final apiService = ref.watch(authControllerProvider.notifier);
//
//   // 2. Call the method you wrote
//   return apiService.fetchAcademicData();
// });

// lib/providers/academic_provider.dart

final academicApiServiceProvider = Provider<AcademicApiService>((ref) {
  return AcademicApiService();
});

final academicDataProvider = FutureProvider<AcademicDashboardData>((ref) async {
  final service = ref.watch(academicApiServiceProvider);
  return service.fetchAcademicData();
});
