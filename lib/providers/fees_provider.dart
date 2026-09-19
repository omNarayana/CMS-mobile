import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/fees_service.dart';
import '../models/fees_model.dart';

final feesApiServiceProvider = Provider((ref) => FeesApiService());

final feesDataProvider = FutureProvider<FeeDashboardData>((ref) async {
  final apiService = ref.watch(feesApiServiceProvider);
  return apiService.fetchFeeDashboard();
});