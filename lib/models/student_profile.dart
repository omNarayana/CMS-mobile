// lib/models/student_profile.dart

class StudentProfile {
  final String id;
  final String name;
  final String email;
  final String studentCode;
  final String tenantName;
  final String locationPlace;
  final String programName;
  final String batchName;

  StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.studentCode,
    required this.tenantName,
    required this.locationPlace,
    required this.programName,
    required this.batchName,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    // Safely extract the nested student maps from your JSON payload
    final studentData = json['student'] as Map<String, dynamic>?;
    final programData = studentData?['program'] as Map<String, dynamic>?;
    final batchData = studentData?['batch'] as Map<String, dynamic>?;

    return StudentProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      studentCode: json['studentCode'] ?? 'N/A',
      tenantName: json['tenant_name'] ?? 'N/A',
      // Maps 'location_name' from the JSON to 'locationPlace' used in the UI
      locationPlace: json['location_name'] ?? 'N/A',
      programName: programData?['name'] ?? 'N/A',
      batchName: batchData?['name'] ?? 'N/A', // Resolves the batchName error
    );
  }
}