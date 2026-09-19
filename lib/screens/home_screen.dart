import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
// Import the file where your selectedTabProvider is located (e.g., main_screen.dart)

import 'fees_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);
    final studentName = profileAsync.valueOrNull?.name ?? "Student";

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              _buildHeader(studentName),
              const SizedBox(height: 25),

              // --- Academic Metrics ---
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                        "Attendance",
                        "84%",
                        Icons.analytics_rounded,
                        Colors.blueAccent
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                        "GPA",
                        "3.8",
                        Icons.auto_awesome_rounded,
                        Colors.orangeAccent
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // --- Announcement Banner ---
              _buildBanner(),
              const SizedBox(height: 30),

              // --- Feature Grid ---
              const Text(
                "University Services",
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.3,
                children: [ // Removed const keyword from here to allow dynamic callbacks
                  const _FeatureItem(
                    Icons.assignment_outlined,
                    "Exams",
                    "2 Upcoming",
                  ),
                  _FeatureItem(
                    Icons.account_balance_wallet_outlined,
                    "Fees",
                    "No Dues",
                    onTap: () {
                      // Open Fees Screen as a standalone sub-page route
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeesScreen(),
                        ),
                      );
                    },
                  ),
                  const _FeatureItem(
                    Icons.calendar_today_outlined,
                    "Events",
                    "1 Today",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "Morning,",
                style: TextStyle(color: Colors.black54, fontSize: 16)
            ),
            Text(
                name,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                )
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
              value,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold
              )
          ),
          Text(
              label,
              style: const TextStyle(color: Colors.black45, fontSize: 13)
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "Next Class:",
              style: TextStyle(color: Colors.white70, fontSize: 12)
          ),
          SizedBox(height: 5),
          Text(
              "Software Engineering",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              )
          ),
          SizedBox(height: 5),
          Text(
              "Room 302 • 10:30 AM",
              style: TextStyle(color: Colors.white70, fontSize: 14)
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap; // Added optional callback parameter

  const _FeatureItem(
      this.icon,
      this.title,
      this.subtitle, {
        this.onTap,
      });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.blueAccent, size: 30),
              const SizedBox(height: 10),
              Text(
                  title,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold
                  )
              ),
              Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black38, fontSize: 11)
              ),
            ],
          ),
        ),
      ),
    );
  }
}