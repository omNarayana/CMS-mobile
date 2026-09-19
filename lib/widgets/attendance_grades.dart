import 'package:flutter/material.dart';
import '../models/academic_model.dart';
import '../theme/academic_theme.dart';

/// Real data view detailing subject-wise attendance health and continuous evaluation grades.
class AttendanceGradesView extends StatelessWidget {
  final List<SubjectCourse> subjects;
  final double? overallAttendance;

  const AttendanceGradesView({
    Key? key,
    required this.subjects,
    this.overallAttendance,
  }) : super(key: key);

  Color _getHealthColor(double percentage) {
    if (percentage >= 85) return AcademicTheme.success;
    if (percentage >= 75) return AcademicTheme.warning;
    return AcademicTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final attValue = overallAttendance ?? 0.0;
    final healthColor = _getHealthColor(attValue);

    int totalAttended = 0;
    int totalDelivered = 0;
    for (var s in subjects) {
      totalAttended += s.attendedClasses;
      totalDelivered += s.totalClasses;
    }

    if (subjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 52,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              ),
              const SizedBox(height: 14),
              Text(
                'No Attendance or Grade Records Yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AcademicTheme.textPrimaryDark
                      : AcademicTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Attendance records will appear here as faculty submit lecture registers for your active courses.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AcademicTheme.textSecondaryDark
                      : AcademicTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: [
        // Overall Attendance Health Banner
        Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: isDark ? AcademicTheme.cardDark : AcademicTheme.cardLight,
            borderRadius: AcademicTheme.borderRadiusMd,
            border: Border.all(
              color: isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight,
            ),
            boxShadow: isDark ? AcademicTheme.darkCardShadow : AcademicTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cumulative Attendance',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AcademicTheme.textSecondaryDark
                              : AcademicTheme.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            overallAttendance != null
                                ? '${overallAttendance!.toStringAsFixed(1)}%'
                                : '--',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: overallAttendance != null ? healthColor : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (overallAttendance != null)
                            Text(
                              overallAttendance! >= 75
                                  ? 'Eligible for Exams'
                                  : 'Short of Mandatory 75%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: healthColor,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (overallAttendance != null ? healthColor : Colors.grey).withOpacity(0.12),
                    ),
                    child: Center(
                      child: Icon(
                        overallAttendance != null && overallAttendance! >= 75
                            ? Icons.verified_user_outlined
                            : Icons.assessment_outlined,
                        color: overallAttendance != null ? healthColor : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                totalDelivered > 0
                    ? 'Attended $totalAttended of $totalDelivered total semester lectures scheduled across all registered subjects.'
                    : 'Class register logs are updating for the active semester.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark
                      ? AcademicTheme.textMutedDark
                      : AcademicTheme.textMutedLight,
                ),
              ),
              if (totalDelivered > 0) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (totalAttended / totalDelivered).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Section Title
        Text(
          'Subject-wise Breakdown & Performance',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AcademicTheme.textPrimaryDark
                : AcademicTheme.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 10),

        // Subject cards with progress
        ...subjects.map((sub) {
          final hasClasses = sub.totalClasses > 0;
          final subHealth = _getHealthColor(sub.attendancePercentage);
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark ? AcademicTheme.cardDark : AcademicTheme.cardLight,
              borderRadius: AcademicTheme.borderRadiusMd,
              border: Border.all(
                color: isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight,
              ),
              boxShadow: isDark ? AcademicTheme.darkCardShadow : AcademicTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.code,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AcademicTheme.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sub.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AcademicTheme.textPrimaryDark
                                  : AcademicTheme.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Grade Badge
                    if (sub.letterGrade != null && sub.letterGrade!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AcademicTheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Grade ${sub.letterGrade}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AcademicTheme.primaryLight,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (hasClasses) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance: ${sub.attendedClasses}/${sub.totalClasses} classes',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AcademicTheme.textSecondaryDark
                              : AcademicTheme.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${sub.attendancePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: subHealth,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (sub.attendedClasses / sub.totalClasses).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.08)
                          : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(subHealth),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Credits: ${sub.credits} • ${sub.type}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AcademicTheme.textSecondaryDark
                          : AcademicTheme.textSecondaryLight,
                    ),
                  ),
                ],
                if (sub.internalScore != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Continuous Internal Assessment (CIE)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? AcademicTheme.textMutedDark
                              : AcademicTheme.textMutedLight,
                        ),
                      ),
                      Text(
                        '${sub.internalScore!.toStringAsFixed(1)} / ${sub.marksConfig.internalMax.toInt()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AcademicTheme.textPrimaryDark
                              : AcademicTheme.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
