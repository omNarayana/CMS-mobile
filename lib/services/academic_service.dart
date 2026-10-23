// lib/services/academic_service.dart
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart'; // Or your Dio instance with ApiInterceptors
import '../models/academic_model.dart';

class AcademicApiService {
  final Dio _dio = DioClient.dio; // Use your configured Dio instance

  Future<AcademicDashboardData> fetchAcademicData() async {
    try {
      // 1. Fetch Subjects, Faculty, and History concurrently
      final responses = await Future.wait([
        _dio.get('/student/portal/subjects'),
        _dio.get('/student/portal/faculty'),
        _dio.get('/student/portal/enrollments'),
      ]);

      final subjectsRes = responses[0].data;
      final facultyRes = responses[1].data;
      final enrollmentsRes = responses[2].data;

      final subjectsData = (subjectsRes['data'] as Map<String, dynamic>?) ?? {};
      final facultyList = (facultyRes['data'] as List<dynamic>?) ?? [];
      final enrollmentsList = (enrollmentsRes['data'] as List<dynamic>?) ?? [];

      // 2. Parse Faculty Members
      final facultyMembers = facultyList
          .map((f) => FacultyInstructor.fromJson(f as Map<String, dynamic>))
          .toList();

      // 3. Parse Enrollment History
      final enrollmentHistory = enrollmentsList
          .map((e) => EnrollmentRecord.fromJson(e as Map<String, dynamic>))
          .toList();

      // 4. Parse base data from /subjects payload
      final dashboard = AcademicDashboardData.fromJson(subjectsData);

      // 5. Construct complete AcademicDashboardData with electiveBaskets forwarded
      return AcademicDashboardData(
        student: dashboard.student,
        activeEnrollment: dashboard.activeEnrollment,
        curriculum: dashboard.curriculum,
        termSubjects: dashboard.termSubjects,
        electiveBaskets: dashboard.electiveBaskets,
        totalCredits: dashboard.totalCredits,
        cgpa: dashboard.cgpa,
        overallAttendance: dashboard.overallAttendance,
        facultyMembers: facultyMembers,
        enrollmentHistory: enrollmentHistory,
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to load academic data (${e.type})';
      throw Exception(msg);
    }
  }

  /// Batch submit all selected elective subjects in one call
  Future<void> selectElectivesBatch({
    required String registrationId,
    required List<Map<String, dynamic>> subjects,
  }) async {
    try {
      await _dio.post(
        '/v1/academic/semester-registration/$registrationId/subjects',
        data: {'subjects': subjects},
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to add elective subjects';
      throw Exception(msg);
    }
  }

  /// Single elective subject selection helper
  Future<void> selectElectiveSubject({
    required String registrationId,
    required String subjectId,
    required String electiveBasketId,
  }) async {
    try {
      await _dio.post(
        '/v1/academic/semester-registration/$registrationId/subjects',
        data: {
          'subjects': [
            {
              'subject': subjectId,
              'elective_basket_id': electiveBasketId,
              'selection_type': 'ELECTIVE',
            }
          ]
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to select elective';
      throw Exception(msg);
    }
  }

  /// Finalize and submit the term registration for approval
  Future<void> submitRegistration({
    required String registrationId,
    String? remarks,
  }) async {
    try {
      await _dio.post(
        '/v1/academic/semester-registration/$registrationId/submit',
        data: {
          'student_remarks': remarks ?? 'Electives selected via Student Portal App',
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to submit registration';
      throw Exception(msg);
    }
  }
}
