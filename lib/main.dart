import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutterapp/app/splash_screen.dart';
import 'package:flutterapp/providers/auth_provider.dart';
import 'package:flutterapp/features/auth/screens/login_screen.dart';
import 'package:flutterapp/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student App',

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: Colors.white,

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.blue.withOpacity(0.15),
        ),
      ),

      home: authState.when(
        data: (token) {
          if (token != null && token.isNotEmpty) {
            return const MainScreen();
          }

          return const LoginScreen();
        },

        loading: () => const SplashScreen(),

        error: (err, stack) {
          debugPrint('Auth error: $err');
          return const LoginScreen();
        },
      ),
    );
  }
}
