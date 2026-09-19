import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/academic_model.dart';
import '../providers/academic_provider.dart'; // Ensure your provider is defined here
import '../theme/academic_theme.dart';
import '../widgets/academic_header_card.dart';
import '../widgets/subject_card.dart';
import '../widgets/faculty_card.dart';
import '../widgets/enrollment_timeline_tile.dart';
import '../widgets/attendance_grades.dart';

/// Refactored Academic Screen using Riverpod for State Management.
class AcademicScreen extends ConsumerStatefulWidget {
  const AcademicScreen({super.key});

  @override
  ConsumerState<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends ConsumerState<AcademicScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Local UI state for searching/filtering
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  bool _showSearchBar = false;
  final List<String> _categories = ['ALL', 'CORE', 'ELECTIVE', 'LAB', 'PROJECT'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the academic data provider
    final academicAsync = ref.watch(academicDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Return a Container (not Scaffold) to keep Tabs visible
    return Container(
      color: isDark ? AcademicTheme.backgroundDark : AcademicTheme.backgroundLight,
      child: SafeArea(
        child: academicAsync.when(
          loading: () => _buildLoadingState(isDark),
          error: (err, stack) => _buildErrorState(isDark, err.toString()),
          data: (data) => _buildContent(context, data, isDark),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AcademicDashboardData data, bool isDark) {
    // Filter logic remains the same but uses 'data' from Riverpod
    final filtered = data.termSubjects.where((sub) {
      final matchesSearch = sub.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sub.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'ALL' ||
          sub.category.toUpperCase() == _selectedCategory.toUpperCase();
      return matchesSearch && matchesCategory;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => ref.refresh(academicDataProvider.future),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildHeader(isDark),
          SliverToBoxAdapter(child: AcademicHeaderCard(data: data)),
          if (_showSearchBar) _buildSearchField(isDark),
          _buildPinnedTabBar(isDark, data),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCoursesTab(isDark, filtered, data),
            _buildFacultyTab(isDark, data.facultyMembers),
            AttendanceGradesView(
              subjects: data.termSubjects,
              overallAttendance: data.overallAttendance,
            ),
            _buildHistoryTab(isDark, data),
          ],
        ),
      ),
    );
  }

  // --- UI Helper Components (Extracted for readability) ---

  SliverToBoxAdapter _buildHeader(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Academic Portal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(_showSearchBar ? Icons.close : Icons.search),
              onPressed: () => setState(() => _showSearchBar = !_showSearchBar),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search subjects...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: isDark ? AcademicTheme.cardDark : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  SliverPersistentHeader _buildPinnedTabBar(bool isDark, AcademicDashboardData data) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AcademicTheme.primaryLight,
          tabs: [
            Tab(text: 'Courses (${data.termSubjects.length})'),
            Tab(text: 'Faculty (${data.facultyMembers.length})'),
            const Tab(text: 'Attendance & Grades'),
            Tab(text: 'History (${data.enrollmentHistory.length})'),
          ],
        ),
        backgroundColor: isDark ? AcademicTheme.backgroundDark : AcademicTheme.backgroundLight,
      ),
    );
  }
  // ─── TAB 1: COURSES ────────────────────────────────────────────────────────
  Widget _buildCoursesTab(bool isDark, List<SubjectCourse> filtered, AcademicDashboardData data) {
    return CustomScrollView(
      slivers: [
        // Category Filter Chips
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    onSelected: (bool selected) {
                      setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AcademicTheme.primaryLight,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Subject List
        if (filtered.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text("No subjects found matching filters.")),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => SubjectCard(
                subject: filtered[index],
                onFacultyTap: () => _tabController.animateTo(1),
              ),
              childCount: filtered.length,
            ),
          ),
      ],
    );
  }

  // ─── TAB 2: FACULTY ────────────────────────────────────────────────────────
  Widget _buildFacultyTab(bool isDark, List<FacultyInstructor> faculty) {
    if (faculty.isEmpty) {
      return const Center(child: Text("No faculty records available."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: faculty.length,
      itemBuilder: (context, index) => FacultyCard(faculty: faculty[index]),
    );
  }

  // ─── TAB 4: HISTORY ────────────────────────────────────────────────────────
  Widget _buildHistoryTab(bool isDark, AcademicDashboardData data) {
    final history = data.enrollmentHistory;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        return EnrollmentTimelineTile(
          record: history[index],
          isFirst: index == 0,
          isLast: index == history.length - 1,
          isCurrent: false,
        );
      },
    );
  }
  // ... (Keep your _buildCoursesTab, _buildFacultyTab, and _buildHistoryTab logic here)

  Widget _buildLoadingState(bool isDark) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          ElevatedButton(
            onPressed: () => ref.invalidate(academicDataProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, {required this.backgroundColor});

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
// Keep your _SliverAppBarDelegate class at the bottom