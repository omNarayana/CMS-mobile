import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/student_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final theme = Theme.of(context);

    // CHANGED: Use Container with white background instead of Scaffold
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text("Failed to load profile", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showLogoutConfirmation(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout Account"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (student) {
            if (student == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text("No Profile Data Found", style: theme.textTheme.titleMedium),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showLogoutConfirmation(context, ref),
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout Account"),
                      ),
                    ],
                  ),
                ),
              );
            }

            final initials = student.name.trim().isNotEmpty
                ? student.name.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
                : 'S';

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // --- CHANGED: Custom Header to replace the old AppBar ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40), // Spacer to center title
                        Text(
                            "Student Profile",
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.redAccent),
                          tooltip: "Logout Account",
                          onPressed: () => _showLogoutConfirmation(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Header Profile Avatar Section ---
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student.name.toUpperCase(),
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.email,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    // --- Section 1: Academic Data ---
                    _buildSectionLabel(context, "Academic Details"),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(Icons.badge_outlined, "Student ID", student.studentCode),
                          const Divider(height: 1, indent: 56, endIndent: 16),
                          _buildInfoTile(Icons.school_outlined, "Program / Course", student.programName),
                          const Divider(height: 1, indent: 56, endIndent: 16),
                          _buildInfoTile(Icons.class_outlined, "Current Batch", student.batchName),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Section 2: Campus Institutional Data ---
                    _buildSectionLabel(context, "Institutional Details"),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      color: Colors.grey[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(Icons.account_balance_outlined, "Institution", student.tenantName),
                          const Divider(height: 1, indent: 56, endIndent: 16),
                          _buildInfoTile(Icons.location_on_outlined, "Campus Location", student.locationPlace),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- System Action Logout Button ---
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutConfirmation(context, ref),
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text("Logout Account"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildSectionLabel(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to end your active session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              ref.read(authControllerProvider.notifier).handleLogout();
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}