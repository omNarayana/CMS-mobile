import 'package:dio/dio.dart';
import '../models/academic_model.dart';
import '../core/network/dio_client.dart';

class AcademicApiService {
  // Use the pre-configured Dio instance
  final Dio _dio = DioClient.dio;

  Future<AcademicDashboardData> fetchAcademicData() async {
    try {
      // Dio combines this with "https://192.168.31.63:5005" automatically
      final response = await _dio.get('/v1/student/portal/subjects');

      // Dio handles JSON decoding automatically
      final payload = response.data['data'] ?? response.data;
      final baseData = AcademicDashboardData.fromJson(payload);

      // Concurrent fetching for performance
      final results = await Future.wait([
        fetchFacultyList(),
        fetchEnrollmentHistory(),
      ]);

      return AcademicDashboardData(
        student: baseData.student,
        activeEnrollment: baseData.activeEnrollment,
        curriculum: baseData.curriculum,
        termSubjects: baseData.termSubjects,
        totalCredits: baseData.totalCredits,
        cgpa: baseData.cgpa,
        overallAttendance: baseData.overallAttendance,
        enrollmentHistory: results[1] as List<EnrollmentRecord>,
        facultyMembers: results[0] as List<FacultyInstructor>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<FacultyInstructor>> fetchFacultyList() async {
    try {
      final response = await _dio.get('/student/portal/faculty');
      final list = (response.data['data'] as List<dynamic>?) ?? [];
      return list.map((item) => FacultyInstructor.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<EnrollmentRecord>> fetchEnrollmentHistory() async {
    try {
      final response = await _dio.get('/student/portal/enrollments');
      final list = (response.data['data'] as List<dynamic>?) ?? [];
      return list.map((item) => EnrollmentRecord.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Exception _handleError(DioException e) {
    // Access error messages sent by your backend
    final message = e.response?.data?['message'] ?? 'Connection error: ${e.type}';
    return Exception(message);
  }
}