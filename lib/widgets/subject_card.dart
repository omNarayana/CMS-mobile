import 'package:flutter/material.dart';
import '../models/academic_model.dart';
import '../theme/academic_theme.dart';

/// Interactive card presenting a course/subject with grading scheme & faculty details.
class SubjectCard extends StatefulWidget {
  final SubjectCourse subject;
  final VoidCallback? onFacultyTap;

  const SubjectCard({
    Key? key,
    required this.subject,
    this.onFacultyTap,
  }) : super(key: key);

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool _isExpanded = false;

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'CORE':
        return AcademicTheme.primaryLight;
      case 'ELECTIVE':
        return AcademicTheme.violetAccent;
      case 'LAB':
      case 'PRACTICAL / LAB':
        return AcademicTheme.accent;
      case 'PROJECT':
        return const Color(0xFFF59E0B);
      default:
        return AcademicTheme.info;
    }
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 85) return AcademicTheme.success;
    if (percentage >= 75) return AcademicTheme.warning;
    return AcademicTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sub = widget.subject;
    final categoryColor = _getCategoryColor(sub.category);
    final attendanceColor = _getAttendanceColor(sub.attendancePercentage);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: isDark ? AcademicTheme.cardDark : AcademicTheme.cardLight,
        borderRadius: AcademicTheme.borderRadiusMd,
        border: Border.all(
          color: isDark ? AcademicTheme.borderDark : AcademicTheme.borderLight,
          width: 1.0,
        ),
        boxShadow: isDark ? AcademicTheme.darkCardShadow : AcademicTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AcademicTheme.borderRadiusMd,
        child: InkWell(
          borderRadius: AcademicTheme.borderRadiusMd,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Course Code, Category Pill, Credits Badge
                Row(
                  children: [
                    // Code Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: categoryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        sub.code,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Category Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sub.category.replaceAll('_', ' '),
                        style: TextStyle(
                          color: isDark
                              ? AcademicTheme.textSecondaryDark
                              : AcademicTheme.textSecondaryLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Credits Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AcademicTheme.creditBadgeGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${sub.credits} ${sub.credits == 1 ? 'Credit' : 'Credits'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Course Title
                Text(
                  sub.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AcademicTheme.textPrimaryDark
                        : AcademicTheme.textPrimaryLight,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Quick Summary Row: Attendance Mini Indicator & Instructor Name
                Row(
                  children: [
                    // Attendance Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: attendanceColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 13,
                            color: attendanceColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${sub.attendancePercentage.toStringAsFixed(0)}% Attended',
                            style: TextStyle(
                              color: attendanceColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Instructor Name
                    if (sub.instructor != null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: isDark
                                  ? AcademicTheme.textMutedDark
                                  : AcademicTheme.textMutedLight,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                sub.instructor!.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AcademicTheme.textSecondaryDark
                                      : AcademicTheme.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Expand Icon
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: isDark
                          ? AcademicTheme.textMutedDark
                          : AcademicTheme.textMutedLight,
                      size: 20,
                    ),
                  ],
                ),

                // Animated Expanded Content: Marks Scheme, Class Attendance bar, Faculty Contact
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 14),

                        // Section 1: Evaluation & Marks Scheme
                        Text(
                          'Evaluation Scheme',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark
                                ? AcademicTheme.textMutedDark
                                : AcademicTheme.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AcademicTheme.cardElevatedDark
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _MarksStat(
                                label: 'Internal (CIE)',
                                value: '${sub.marksConfig.internalMax.toInt()} pts',
                                scored: sub.internalScore != null
                                    ? '${sub.internalScore!.toStringAsFixed(1)} scored'
                                    : null,
                              ),
                              Container(
                                height: 32,
                                width: 1,
                                color: isDark ? Colors.white12 : Colors.black12,
                              ),
                              _MarksStat(
                                label: 'External (SEE)',
                                value: '${sub.marksConfig.externalMax.toInt()} pts',
                                scored: sub.externalScore != null
                                    ? '${sub.externalScore!.toStringAsFixed(1)} scored'
                                    : null,
                              ),
                              Container(
                                height: 32,
                                width: 1,
                                color: isDark ? Colors.white12 : Colors.black12,
                              ),
                              _MarksStat(
                                label: 'Passing Min',
                                value: '${sub.marksConfig.passingPercentage.toInt()}%',
                                scored: sub.letterGrade != null
                                    ? 'Grade: ${sub.letterGrade}'
                                    : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Section 2: Attendance Tracking Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Class Attendance',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AcademicTheme.textSecondaryDark
                                    : AcademicTheme.textSecondaryLight,
                              ),
                            ),
                            Text(
                              '${sub.attendedClasses} / ${sub.totalClasses} Lectures',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: attendanceColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: sub.totalClasses > 0
                                ? (sub.attendedClasses / sub.totalClasses).clamp(0.0, 1.0)
                                : 0.0,
                            minHeight: 7,
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.08)
                                : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(attendanceColor),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Section 3: Assigned Faculty Tile
                        if (sub.instructor != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.03)
                                  : Colors.grey.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.black.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AcademicTheme.primaryLight,
                                  backgroundImage: sub.instructor!.profileImageUrl != null
                                      ? NetworkImage(sub.instructor!.profileImageUrl!)
                                      : null,
                                  child: sub.instructor!.profileImageUrl == null
                                      ? Text(
                                    sub.instructor!.name.isNotEmpty
                                        ? sub.instructor!.name[0]
                                        : 'F',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sub.instructor!.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: isDark
                                              ? AcademicTheme.textPrimaryDark
                                              : AcademicTheme.textPrimaryLight,
                                        ),
                                      ),
                                      Text(
                                        sub.instructor!.designation ?? 'Faculty Instructor',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? AcademicTheme.textMutedDark
                                              : AcademicTheme.textMutedLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.onFacultyTap != null)
                                  TextButton.icon(
                                    onPressed: widget.onFacultyTap,
                                    icon: const Icon(Icons.arrow_forward, size: 14),
                                    label: const Text('Profile'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AcademicTheme.accent,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarksStat extends StatelessWidget {
  final String label;
  final String value;
  final String? scored;

  const _MarksStat({
    Key? key,
    required this.label,
    required this.value,
    this.scored,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AcademicTheme.textMutedDark
                : AcademicTheme.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AcademicTheme.textPrimaryDark
                : AcademicTheme.textPrimaryLight,
          ),
        ),
        if (scored != null) ...[
          const SizedBox(height: 2),
          Text(
            scored!,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AcademicTheme.success,
            ),
          ),
        ],
      ],
    );
  }
}
