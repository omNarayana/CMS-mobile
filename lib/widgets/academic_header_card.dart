import 'package:flutter/material.dart';
import '../models/academic_model.dart';
import '../theme/academic_theme.dart';

/// Hero header card showcasing live current active term, student cohort, and academic metrics.
class AcademicHeaderCard extends StatelessWidget {
  final AcademicDashboardData data;

  const AcademicHeaderCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = data.activeEnrollment;
    final student = data.student;
    final program = student.programName ??
        (student.programCode != null ? 'Program: ${student.programCode}' : 'Active Academic Student');
    final rollCode = student.code;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: AcademicTheme.academicHeaderGradient,
        borderRadius: AcademicTheme.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withOpacity(isDark ? 0.4 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient circles
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AcademicTheme.accent.withOpacity(0.12),
              ),
            ),
          ),

          // Main Header Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Active Semester Pill & Student Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active != null
                                  ? AcademicTheme.success
                                  : AcademicTheme.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            active?.termName.isNotEmpty == true
                                ? active!.termName
                                : (active != null ? 'Semester ${active.termNumber}' : 'Enrolled Student'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (rollCode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rollCode,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Program Title
                Text(
                  program,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Academic Year & Section
                Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 15,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      active?.academicYearName.isNotEmpty == true
                          ? active!.academicYearName
                          : 'Academic Year',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (active?.sectionName != null && active!.sectionName!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '•',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                      Text(
                        active.sectionName!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 20),

                // 3 Key Metric Stats (CGPA, Term Credits, Attendance)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: AcademicTheme.borderRadiusMd,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // CGPA Metric
                      Expanded(
                        child: _MetricTile(
                          icon: Icons.auto_awesome,
                          iconColor: const Color(0xFFFBBF24),
                          label: 'CGPA',
                          value: data.cgpa != null
                              ? data.cgpa!.toStringAsFixed(2)
                              : '--',
                          sublabel: data.cgpa != null ? 'Out of 10.0' : 'In Progress',
                        ),
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      // Credits Metric
                      Expanded(
                        child: _MetricTile(
                          icon: Icons.layers_outlined,
                          iconColor: const Color(0xFF67E8F9),
                          label: 'Term Credits',
                          value: '${data.totalCredits}',
                          sublabel: data.curriculum != null && data.curriculum!.totalCredits > 0
                              ? '${data.curriculum!.totalCredits} Scheme Total'
                              : 'Registered',
                        ),
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      // Attendance Metric
                      Expanded(
                        child: _MetricTile(
                          icon: Icons.verified_outlined,
                          iconColor: const Color(0xFF34D399),
                          label: 'Attendance',
                          value: data.overallAttendance != null
                              ? '${data.overallAttendance!.toStringAsFixed(1)}%'
                              : '--',
                          sublabel: data.overallAttendance != null
                              ? (data.overallAttendance! >= 75 ? 'Eligible' : 'Low Status')
                              : 'No Records',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sublabel;

  const _MetricTile({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sublabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          sublabel,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 9.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
