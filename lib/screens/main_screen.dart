import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_screen.dart';
import 'profile_screen.dart';
import 'academic_screen.dart';
// import 'fees_screen.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);

    final List<Widget> screens = [
      const HomeScreen(),
      const AcademicScreen(), // Mount it here
      const ProfileScreen(),
      // const FeesScreen(),
    ];

    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   // appBar: AppBar(
    //   //   backgroundColor: Colors.red,
    //   //   title: const Text('IF YOU SEE THIS RED BAR, MAIN_SCREEN IS ACTIVE'),
    //   // ),
    //   body: IndexedStack(
    //     index: selectedIndex,
    //     children: screens,
    //   ),
    //
    //   bottomNavigationBar: Container(
    //     decoration: BoxDecoration(
    //       border: Border(
    //         top: BorderSide(
    //           color: Colors.grey.shade200,
    //           width: 1,
    //         ),
    //       ),
    //     ),
    //
    //     child: NavigationBar(
    //       backgroundColor: Colors.white,
    //       elevation: 0,
    //
    //       selectedIndex: selectedIndex,
    //
    //       labelBehavior:
    //       NavigationDestinationLabelBehavior.alwaysShow,
    //
    //       onDestinationSelected: (index) {
    //         debugPrint('==============================');
    //         debugPrint('Navigation Destination Selected');
    //         debugPrint('Index: $index');
    //
    //         if (index == 0) {
    //           debugPrint('Screen: Home');
    //         } else if (index == 1) {
    //           debugPrint('Screen: Profile');
    //         }
    //
    //         debugPrint('==============================');
    //
    //         ref.read(selectedTabProvider.notifier).state = index;
    //       },
    //
    //       destinations: const [
    //         NavigationDestination(
    //           icon: Icon(Icons.dashboard_outlined),
    //           selectedIcon: Icon(
    //             Icons.dashboard,
    //             color: Colors.blue,
    //           ),
    //           label: 'Home',
    //         ),
    //
    //         NavigationDestination(
    //           icon: Icon(Icons.person_outline),
    //           selectedIcon: Icon(
    //             Icons.person,
    //             color: Colors.blue,
    //           ),
    //           label: 'Profile',
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },
        // 2. Add the Academic destination icon here
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school),
      label: 'Academic', // This corresponds to index 1
    ),
    NavigationDestination(
    icon: Icon(Icons.person_outline),
    selectedIcon: Icon(Icons.person),
    label: 'Profile',
    ),
    ],
    ),
    );
  }
}
