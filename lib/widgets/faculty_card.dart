import 'package:flutter/material.dart';
import '../models/academic_model.dart';
import '../theme/academic_theme.dart';

/// Card presenting a faculty professor with department credentials and quick contact buttons.
class FacultyCard extends StatelessWidget {
  final FacultyInstructor faculty;
  final VoidCallback? onEmailTap;
  final VoidCallback? onOfficeHoursTap;

  const FacultyCard({
    Key? key,
    required this.faculty,
    this.onEmailTap,
    this.onOfficeHoursTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Faculty Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AcademicTheme.primaryLight, AcademicTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AcademicTheme.primary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: faculty.profileImageUrl != null
                      ? ClipOval(
                    child: Image.network(
                      faculty.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _FallbackAvatar(name: faculty.name),
                    ),
                  )
                      : _FallbackAvatar(name: faculty.name),
                ),
                const SizedBox(width: 14),

                // Name & Credentials
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              faculty.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AcademicTheme.textPrimaryDark
                                    : AcademicTheme.textPrimaryLight,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AcademicTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              faculty.role ?? 'Faculty',
                              style: const TextStyle(
                                color: AcademicTheme.primaryLight,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        faculty.designation ?? 'Faculty Instructor',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AcademicTheme.textSecondaryDark
                              : AcademicTheme.textSecondaryLight,
                        ),
                      ),
                      if (faculty.department != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 13,
                              color: isDark
                                  ? AcademicTheme.textMutedDark
                                  : AcademicTheme.textMutedLight,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                faculty.department!,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? AcademicTheme.textMutedDark
                                      : AcademicTheme.textMutedLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Assigned Subjects Chips
            if (faculty.subjectsTaught.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: faculty.subjectsTaught.map((subName) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      subName,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AcademicTheme.textSecondaryDark
                            : AcademicTheme.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Quick Action Buttons (Email & Office Hours)
            Row(
              children: [
                if (faculty.email != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEmailTap ??
                              () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Composing email to ${faculty.email}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                      icon: const Icon(Icons.mail_outline, size: 15),
                      label: const Text('Email Professor'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : AcademicTheme.primary,
                        side: BorderSide(
                          color: isDark ? Colors.white24 : AcademicTheme.borderLight,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: onOfficeHoursTap ??
                          () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (ctx) => _OfficeHoursModal(faculty: faculty),
                        );
                      },
                  tooltip: 'View Office Hours',
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AcademicTheme.accent.withOpacity(0.12),
                    foregroundColor: AcademicTheme.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  final String name;

  const _FallbackAvatar({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'P',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _OfficeHoursModal extends StatelessWidget {
  final FacultyInstructor faculty;

  const _OfficeHoursModal({Key? key, required this.faculty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: AcademicTheme.accent),
              const SizedBox(width: 8),
              Text(
                'Faculty Office Hours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AcademicTheme.textPrimaryDark
                      : AcademicTheme.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            faculty.name,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AcademicTheme.textSecondaryDark
                  : AcademicTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          _officeHourItem('Mon & Wed', '03:00 PM – 05:00 PM', 'Faculty Cabin #304'),
          _officeHourItem('Friday', '11:00 AM – 01:00 PM', 'Virtual Google Meet'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AcademicTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _officeHourItem(String days, String time, String location) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 85,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AcademicTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              days,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AcademicTheme.primaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  location,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
