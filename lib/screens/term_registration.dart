// lib/screens/term_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/academic_model.dart';
import '../providers/academic_provider.dart';
import '../theme/academic_theme.dart';
import '../services/academic_service.dart';

class TermRegistrationScreen extends ConsumerStatefulWidget {
  final String termId;
  final String termName;
  final List<SubjectCourse> coreSubjects;
  final List<ElectiveBasket> electiveBaskets;

  const TermRegistrationScreen({
    super.key,
    required this.termId,
    required this.termName,
    required this.coreSubjects,
    required this.electiveBaskets,
  });

  @override
  ConsumerState<TermRegistrationScreen> createState() => _TermRegistrationScreenState();
}

class _TermRegistrationScreenState extends ConsumerState<TermRegistrationScreen> {
  // Map of basketId -> selected subjectId
  final Map<String, String> _selectedElectives = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate total credits (Core credits + selected Electives credits)
    int coreCredits = widget.coreSubjects.fold(0, (sum, s) => sum + s.credits);
    int electiveCredits = widget.electiveBaskets.fold(0, (sum, b) {
      return _selectedElectives.containsKey(b.id) ? sum + b.credits : sum;
    });
    int totalCredits = coreCredits + electiveCredits;

    return Scaffold(
      backgroundColor: isDark ? AcademicTheme.backgroundDark : AcademicTheme.backgroundLight,
      appBar: AppBar(
        title: Text('${widget.termName} Registration'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ── Header Summary Card ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AcademicTheme.academicHeaderGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.termName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select your electives to complete registration',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalCredits Credits',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Section 1: Compulsory Core Subjects ──
          Text(
            'Compulsory Core Subjects (${widget.coreSubjects.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'These subjects are automatically registered for your degree.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 10),

          ...widget.coreSubjects.map((sub) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE0E7FF),
                child: Icon(Icons.lock_outline, color: Color(0xFF4338CA), size: 18),
              ),
              title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${sub.code} • ${sub.type}'),
              trailing: Text(
                '${sub.credits} Credits',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )),

          const SizedBox(height: 24),

          // ── Section 2: Elective Subject Selection ──
          if (widget.electiveBaskets.isNotEmpty) ...[
            const Text(
              'Elective Selection',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Select one course from each elective basket below:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 12),

            ...widget.electiveBaskets.map((basket) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AcademicTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedElectives.containsKey(basket.id)
                        ? AcademicTheme.primaryLight
                        : Colors.grey.shade300,
                    width: _selectedElectives.containsKey(basket.id) ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          basket.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${basket.credits} Credits',
                            style: const TextStyle(
                              color: Color(0xFF6D28D9),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    ...basket.options.map((opt) {
                      final isSelected = _selectedElectives[basket.id] == opt.subjectId;
                      return RadioListTile<String>(
                        value: opt.subjectId,
                        groupValue: _selectedElectives[basket.id],
                        onChanged: (val) {
                          setState(() {
                            _selectedElectives[basket.id] = val!;
                          });
                        },
                        title: Text(opt.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(opt.code),
                        activeColor: AcademicTheme.primaryLight,
                      );
                    }),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 20),

          // ── Submit Button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AcademicTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSubmitting ? null : _submitRegistration,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Submit Term Registration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Future<void> _submitRegistration() async {
    // 1. Validation: ensure every basket has a selection
    for (var b in widget.electiveBaskets) {
      if (!_selectedElectives.containsKey(b.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an option for ${b.name}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final academicService = ref.read(academicApiServiceProvider);

      // 2. Prepare payload of chosen electives
      final electivePayload = _selectedElectives.entries.map((entry) {
        return {
          'subject': entry.value,
          'elective_basket_id': entry.key,
          'selection_type': 'ELECTIVE',
        };
      }).toList();

      // 3. Save selected electives to backend registration
      await academicService.selectElectivesBatch(
        registrationId: widget.termId,
        subjects: electivePayload,
      );

      // 4. Submit the registration (transitions PENDING ➔ SUBMITTED)
      await academicService.submitRegistration(
        registrationId: widget.termId,
        remarks: 'Electives selected via Student Portal App',
      );

      // 5. Invalidate Riverpod cache so AcademicScreen fetches updated data
      ref.invalidate(academicDataProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Electives submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

}
