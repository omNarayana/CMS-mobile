import 'package:flutter/material.dart';
import '../models/academic_model.dart';
import '../theme/academic_theme.dart';

/// Timeline tile depicting semester enrollment history, credits earned, and term SGPA.
class EnrollmentTimelineTile extends StatelessWidget {
  final EnrollmentRecord record;
  final bool isFirst;
  final bool isLast;
  final bool isCurrent;

  const EnrollmentTimelineTile({
    Key? key,
    required this.record,
    this.isFirst = false,
    this.isLast = false,
    this.isCurrent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line & Node indicator
          SizedBox(
            width: 44,
            child: Column(
              children: [
                // Top connecting line
                Expanded(
                  child: Container(
                    width: isFirst ? 0 : 2,
                    color: isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight,
                  ),
                ),
                // Indicator Node
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? AcademicTheme.primaryLight
                        : AcademicTheme.success.withOpacity(0.15),
                    border: Border.all(
                      color: isCurrent ? Colors.white : AcademicTheme.success,
                      width: 2,
                    ),
                    boxShadow: isCurrent
                        ? [
                      BoxShadow(
                        color: AcademicTheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      isCurrent ? Icons.play_arrow : Icons.check,
                      size: 13,
                      color: isCurrent ? Colors.white : AcademicTheme.success,
                    ),
                  ),
                ),
                // Bottom connecting line
                Expanded(
                  child: Container(
                    width: isLast ? 0 : 2,
                    color: isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight,
                  ),
                ),
              ],
            ),
          ),

          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14.0, right: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? AcademicTheme.cardDark : AcademicTheme.cardLight,
                borderRadius: AcademicTheme.borderRadiusMd,
                border: Border.all(
                  color: isCurrent
                      ? AcademicTheme.primaryLight.withOpacity(0.5)
                      : (isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight),
                  width: isCurrent ? 1.5 : 1.0,
                ),
                boxShadow: isDark ? AcademicTheme.darkCardShadow : AcademicTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        record.termName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AcademicTheme.textPrimaryDark
                              : AcademicTheme.textPrimaryLight,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AcademicTheme.primaryLight.withOpacity(0.15)
                              : AcademicTheme.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCurrent ? 'ACTIVE' : record.status,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? AcademicTheme.primaryLight
                                : AcademicTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.academicYear} • ${record.section}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AcademicTheme.textMutedDark
                          : AcademicTheme.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Credits Pill
                      _Badge(
                        label: 'Credits Earned',
                        value: '${record.creditsEarned}',
                        color: AcademicTheme.accent,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      // SGPA Pill
                      _Badge(
                        label: 'Semester GPA',
                        value: record.sgpa?.toStringAsFixed(2) ?? 'N/A',
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _Badge({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AcademicTheme.textSecondaryDark
                  : AcademicTheme.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
