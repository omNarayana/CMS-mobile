/// Strongly-typed real data models reflecting actual backend MongoDB SIS schemas.

class AcademicDashboardData {
  final StudentInfo student;
  final ActiveEnrollment? activeEnrollment;
  final CurriculumScheme? curriculum;
  final List<SubjectCourse> termSubjects;
  final int totalCredits;
  final double? cgpa;
  final double? overallAttendance;
  final List<EnrollmentRecord> enrollmentHistory;
  final List<FacultyInstructor> facultyMembers;

  AcademicDashboardData({
    required this.student,
    this.activeEnrollment,
    this.curriculum,
    required this.termSubjects,
    required this.totalCredits,
    this.cgpa,
    this.overallAttendance,
    this.enrollmentHistory = const [],
    this.facultyMembers = const [],
  });

  factory AcademicDashboardData.fromJson(Map<String, dynamic> json) {
    final studentObj = json['student'] is Map<String, dynamic>
        ? StudentInfo.fromJson(json['student'])
        : StudentInfo(id: '', code: '', name: 'Student');

    final enrollmentObj = json['activeEnrollment'] is Map<String, dynamic>
        ? ActiveEnrollment.fromJson(json['activeEnrollment'])
        : null;

    final curriculumObj = json['curriculum'] is Map<String, dynamic>
        ? CurriculumScheme.fromJson(json['curriculum'])
        : null;

    final rawSubjects = (json['termSubjects'] as List<dynamic>?) ?? [];
    final subjects = rawSubjects
        .map((s) => SubjectCourse.fromJson(s as Map<String, dynamic>))
        .toList();

    // Compute real overall attendance from enrolled subjects if available
    double? computedAttendance;
    int totalAttended = 0;
    int totalClasses = 0;
    for (final s in subjects) {
      if (s.totalClasses > 0) {
        totalAttended += s.attendedClasses;
        totalClasses += s.totalClasses;
      }
    }
    if (totalClasses > 0) {
      computedAttendance = (totalAttended / totalClasses) * 100;
    } else if (json['overallAttendance'] != null) {
      computedAttendance = (json['overallAttendance'] as num).toDouble();
    }

    return AcademicDashboardData(
      student: studentObj,
      activeEnrollment: enrollmentObj,
      curriculum: curriculumObj,
      termSubjects: subjects,
      totalCredits: (json['totalCredits'] as num?)?.toInt() ?? 0,
      cgpa: (json['cgpa'] as num?)?.toDouble(),
      overallAttendance: computedAttendance,
    );
  }
}

class StudentInfo {
  final String id;
  final String code;
  final String name;
  final String? programName;
  final String? programCode;
  final String? degreeType;
  final String? avatarUrl;

  StudentInfo({
    required this.id,
    required this.code,
    required this.name,
    this.programName,
    this.programCode,
    this.degreeType,
    this.avatarUrl,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    final program = json['program'];
    String? pName;
    String? pCode;
    String? dType;

    if (program is Map) {
      pName = program['name']?.toString();
      pCode = program['code']?.toString();
      dType = program['degree_type']?.toString();
    } else {
      pName = json['programName']?.toString();
      pCode = json['programCode']?.toString();
      dType = json['degreeType']?.toString();
    }

    String? avatar;
    if (json['profileImage'] is Map) {
      avatar = json['profileImage']['url']?.toString();
    } else if (json['profileImage'] is String) {
      avatar = json['profileImage'];
    } else {
      avatar = json['avatarUrl']?.toString();
    }

    return StudentInfo(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ??
          '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      programName: pName,
      programCode: pCode,
      degreeType: dType,
      avatarUrl: avatar,
    );
  }
}

class ActiveEnrollment {
  final String id;
  final String academicYearName;
  final String termName;
  final int termNumber;
  final String? termType;
  final String? batchName;
  final String? sectionName;
  final String status;
  final bool isCurrent;

  ActiveEnrollment({
    required this.id,
    required this.academicYearName,
    required this.termName,
    required this.termNumber,
    this.termType,
    this.batchName,
    this.sectionName,
    this.status = 'ENROLLED',
    this.isCurrent = true,
  });

  factory ActiveEnrollment.fromJson(Map<String, dynamic> json) {
    final year = json['academic_year'];
    final yearName = year is Map ? year['name']?.toString() ?? '' : (year?.toString() ?? '');

    final term = json['academic_term'];
    final termName = term is Map ? term['name']?.toString() ?? '' : (term?.toString() ?? '');
    final termNumber = term is Map ? (term['term_number'] as num?)?.toInt() ?? 1 : 1;
    final termType = term is Map ? term['term_type']?.toString() : null;

    final batch = json['batch'];
    final batchName = batch is Map ? batch['name']?.toString() : batch?.toString();

    final section = json['section'];
    final sectionName = section is Map ? section['name']?.toString() : section?.toString();

    return ActiveEnrollment(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      academicYearName: yearName,
      termName: termName,
      termNumber: termNumber,
      termType: termType,
      batchName: batchName,
      sectionName: sectionName,
      status: json['status']?.toString() ?? 'ENROLLED',
      isCurrent: json['isCurrent'] == true || (term is Map && term['isCurrent'] == true),
    );
  }
}

class CurriculumScheme {
  final String id;
  final String name;
  final String code;
  final int? regulationYear;
  final int totalCredits;

  CurriculumScheme({
    required this.id,
    required this.name,
    required this.code,
    this.regulationYear,
    required this.totalCredits,
  });

  factory CurriculumScheme.fromJson(Map<String, dynamic> json) {
    return CurriculumScheme(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Curriculum Scheme',
      code: json['code']?.toString() ?? '',
      regulationYear: (json['regulation_year'] as num?)?.toInt(),
      totalCredits: (json['total_credits'] as num?)?.toInt() ?? 0,
    );
  }
}

class SubjectCourse {
  final String id;
  final String code;
  final String name;
  final String type;
  final String category;
  final int credits;
  final bool isElective;
  final String? electiveGroup;
  final String? department;
  final MarksConfig marksConfig;
  final FacultyInstructor? instructor;
  final double attendancePercentage;
  final int attendedClasses;
  final int totalClasses;
  final String? letterGrade;
  final double? internalScore;
  final double? externalScore;

  SubjectCourse({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.category,
    required this.credits,
    this.isElective = false,
    this.electiveGroup,
    this.department,
    required this.marksConfig,
    this.instructor,
    this.attendancePercentage = 0.0,
    this.attendedClasses = 0,
    this.totalClasses = 0,
    this.letterGrade,
    this.internalScore,
    this.externalScore,
  });

  factory SubjectCourse.fromJson(Map<String, dynamic> json) {
    final subMap = json['subject'] is Map ? json['subject'] as Map<String, dynamic> : <String, dynamic>{};
    final code = subMap['code']?.toString() ?? json['code']?.toString() ?? 'SUB-CODE';
    final name = subMap['name']?.toString() ?? json['name']?.toString() ?? 'Subject';
    final type = subMap['type']?.toString() ?? json['type']?.toString() ?? 'Theory';
    final dept = subMap['department'] is Map
        ? subMap['department']['name']?.toString()
        : subMap['department']?.toString();

    final category = json['course_category']?.toString() ??
        (json['isElective'] == true ? 'ELECTIVE' : 'CORE');

    final credits = (json['credits'] as num?)?.toInt() ??
        (subMap['credits'] as num?)?.toInt() ??
        0;

    final marksMap = json['marks_config'] is Map ? json['marks_config'] as Map<String, dynamic> : null;
    final marks = marksMap != null ? MarksConfig.fromJson(marksMap) : MarksConfig.defaults();

    final instructorMap = json['instructor'] is Map ? json['instructor'] as Map<String, dynamic> : null;
    final instructor = instructorMap != null ? FacultyInstructor.fromJson(instructorMap) : null;

    final att = (json['attendancePercentage'] as num?)?.toDouble() ?? 0.0;
    final attended = (json['attendedClasses'] as num?)?.toInt() ?? 0;
    final total = (json['totalClasses'] as num?)?.toInt() ?? 0;

    return SubjectCourse(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      code: code,
      name: name,
      type: type,
      category: category,
      credits: credits,
      isElective: json['isElective'] == true,
      electiveGroup: json['elective_group']?.toString(),
      department: dept,
      marksConfig: marks,
      instructor: instructor,
      attendancePercentage: att,
      attendedClasses: attended,
      totalClasses: total,
      letterGrade: json['letterGrade']?.toString(),
      internalScore: (json['internalScore'] as num?)?.toDouble(),
      externalScore: (json['externalScore'] as num?)?.toDouble(),
    );
  }
}

class MarksConfig {
  final double internalMax;
  final double externalMax;
  final double passingPercentage;

  MarksConfig({
    required this.internalMax,
    required this.externalMax,
    required this.passingPercentage,
  });

  factory MarksConfig.defaults() => MarksConfig(
    internalMax: 0.0,
    externalMax: 0.0,
    passingPercentage: 40.0,
  );

  factory MarksConfig.fromJson(Map<String, dynamic> json) {
    return MarksConfig(
      internalMax: (json['internal_max'] as num?)?.toDouble() ?? 0.0,
      externalMax: (json['external_max'] as num?)?.toDouble() ?? 0.0,
      passingPercentage: (json['passing_percentage'] as num?)?.toDouble() ?? 40.0,
    );
  }

  double get totalMax => internalMax + externalMax;
}

class FacultyInstructor {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final String? designation;
  final String? department;
  final String? role;
  final List<String> subjectsTaught;

  FacultyInstructor({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.profileImageUrl,
    this.designation,
    this.department,
    this.role,
    this.subjectsTaught = const [],
  });

  factory FacultyInstructor.fromJson(Map<String, dynamic> json) {
    final subList = (json['subjects'] as List<dynamic>?)
        ?.map((s) => s is Map ? s['name']?.toString() ?? '' : s.toString())
        .where((s) => s.isNotEmpty)
        .toList() ??
        [];

    String? avatar;
    if (json['profileImage'] is Map) {
      avatar = json['profileImage']['url']?.toString();
    } else if (json['profileImage'] is String) {
      avatar = json['profileImage'];
    }

    return FacultyInstructor(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ??
          '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      profileImageUrl: avatar,
      designation: json['designation'] is Map
          ? json['designation']['name']?.toString()
          : json['designation']?.toString(),
      department: json['department'] is Map
          ? json['department']['name']?.toString()
          : json['department']?.toString(),
      role: json['role']?.toString() ?? 'Faculty Instructor',
      subjectsTaught: subList,
    );
  }
}

class EnrollmentRecord {
  final String id;
  final String termName;
  final int termNumber;
  final String academicYear;
  final String section;
  final String status;
  final int creditsEarned;
  final double? sgpa;
  final bool isCompleted;

  EnrollmentRecord({
    required this.id,
    required this.termName,
    required this.termNumber,
    required this.academicYear,
    required this.section,
    required this.status,
    required this.creditsEarned,
    this.sgpa,
    this.isCompleted = true,
  });

  factory EnrollmentRecord.fromJson(Map<String, dynamic> json) {
    final term = json['academic_term'];
    final year = json['academic_year'];
    final section = json['section'];

    final termName = term is Map ? term['name']?.toString() ?? 'Term' : (term?.toString() ?? 'Term');
    final termNumber = term is Map ? (term['term_number'] as num?)?.toInt() ?? 1 : 1;
    final yearName = year is Map ? year['name']?.toString() ?? '' : (year?.toString() ?? '');
    final sectionName = section is Map ? section['name']?.toString() ?? '' : (section?.toString() ?? '');

    return EnrollmentRecord(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      termName: termName,
      termNumber: termNumber,
      academicYear: yearName,
      section: sectionName,
      status: json['status']?.toString() ?? 'ENROLLED',
      creditsEarned: (json['creditsEarned'] as num?)?.toInt() ?? 0,
      sgpa: (json['sgpa'] as num?)?.toDouble(),
      isCompleted: json['status'] == 'COMPLETED' || json['status'] == 'PROMOTED',
    );
  }
}
