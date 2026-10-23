import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added
import '../../../services/auth_service.dart';
import '../../../providers/auth_provider.dart'; // Added
import '../../../screens/main_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // 1. Authenticate via Service
      await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // 2. Clear cached provider states so ProfileScreen fetches fresh data
      // This solves the issue where it still shows "Not logged in" after login
      ref.invalidate(authProvider);
      ref.invalidate(profileProvider);

      if (!mounted) return;

      // 3. Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Welcome back!"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 4. Navigate to MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Campus Header / Logo ───
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Student Portal",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sign in to access your academics, attendance & fees",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ─── Email Field ───
                  Text(
                    "Student Email / Registration ID",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "student@university.edu",
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Enter your email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ─── Password Field ───
                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter your password";
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // ─── Sign In Button ───
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                          : const Text("Sign In to SIS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}






//
// import 'package:flutter/material.dart';
// import '../../../services/auth_service.dart';
// import '../../../screens/main_screen.dart'; // Import your MainScreen with tabs!
//
// class LoginScreen extends ConsumerStatefulWidget { // Changed
//   const LoginScreen({super.key});
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState(); // Changed
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen> { // Changed
//   final _formKey = GlobalKey<FormState>();
//   final ApiService _apiService = ApiService();
//
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     FocusScope.of(context).unfocus();
//     setState(() => _isLoading = true);
//
//     try {
//
//       await _apiService.login(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );
//
//       if (!mounted) return;
//
//       // Show Success feedback
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Welcome back!")),
//       );
//
//       // Navigate to MainScreen (or HomeScreen)
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const MainScreen()),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(e.toString().replaceAll("Exception: ", "")),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // ─── Campus Header / Logo ──────────────────────────────────
//                   Center(
//                     child: Container(
//                       width: 76,
//                       height: 76,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(22),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(0xFF2563EB).withOpacity(0.35),
//                             blurRadius: 18,
//                             offset: const Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.school_rounded,
//                         size: 40,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // ─── Welcome Title ────────────────────────────────────────
//                   Text(
//                     "Student Portal",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: -0.5,
//                       color: isDark ? Colors.white : const Color(0xFF0F172A),
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     "Sign in to access your academics, attendance & fees",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
//                     ),
//                   ),
//                   const SizedBox(height: 36),
//
//                   // ─── Email Field ──────────────────────────────────────────
//                   Text(
//                     "Student Email / Registration ID",
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextFormField(
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//                     decoration: InputDecoration(
//                       hintText: "student@university.edu",
//                       hintStyle: TextStyle(
//                         color: isDark ? Colors.white38 : Colors.black38,
//                         fontSize: 14,
//                       ),
//                       filled: true,
//                       fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
//                       prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(
//                           color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(
//                           color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return "Please enter your email or ID";
//                       }
//                       if (!value.contains('@')) {
//                         return "Enter a valid institutional email";
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//
//                   // ─── Password Field ───────────────────────────────────────
//                   Text(
//                     "Password",
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//                     decoration: InputDecoration(
//                       hintText: "Enter your password",
//                       hintStyle: TextStyle(
//                         color: isDark ? Colors.white38 : Colors.black38,
//                         fontSize: 14,
//                       ),
//                       filled: true,
//                       fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
//                       prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility_outlined
//                               : Icons.visibility_off_outlined,
//                           size: 20,
//                         ),
//                         onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(
//                           color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(
//                           color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "Please enter your password";
//                       }
//                       if (value.length < 6) {
//                         return "Password must be at least 6 characters";
//                       }
//                       return null;
//                     },
//                   ),
//
//                   // ─── Forgot Password ──────────────────────────────────────
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: () {
//                         // Hook up forgot password flow if needed
//                       },
//                       child: const Text(
//                         "Forgot Password?",
//                         style: TextStyle(
//                           color: Color(0xFF2563EB),
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//
//                   // ─── Sign In Button ───────────────────────────────────────
//                   SizedBox(
//                     height: 52,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _login,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2563EB),
//                         foregroundColor: Colors.white,
//                         disabledBackgroundColor: const Color(0xFF93C5FD),
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                         width: 22,
//                         height: 22,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2.5,
//                           color: Colors.white,
//                         ),
//                       )
//                           : const Text(
//                         "Sign In to SIS",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 0.2,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 36),
//
//                   // ─── Campus Support Footer ────────────────────────────────
//                   Center(
//                     child: Text(
//                       "Trouble logging in? Contact IT Campus Helpdesk",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//

















// import 'package:flutter/material.dart';
// import '../../../services/auth_service.dart';
// import '../../../core/storage/secure_storage.dart';
// import '../../../screens/home_screen.dart';
//
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiService _apiService = ApiService();
//
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
// print('started');
//     try {
//       final email = _emailController.text.trim();
//       final password = _passwordController.text;
//      print('email,password');
//
//       final response = await _apiService.post(
//         "/v1/user/login",
//         {
//           "email": email,
//           "password": password,
//         },
//       );
//
//       debugPrint("Email: $email");
//       debugPrint("Password: $password");
//       print(response.data.toString());
//
//       final token = response.data["data"]["token"];
//       print('$token token');
//       await TokenStorage.saveToken(token);
//
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Login Successful"),
//         ),
//       );
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const HomeScreen(),
//         ),
//       );
//
//     } catch (e) {
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Login failed: $e"),
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Login"),
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: const InputDecoration(
//                       labelText: "Email",
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.email),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return "Please enter your email";
//                       }
//
//                       if (!value.contains('@')) {
//                         return "Enter a valid email";
//                       }
//
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     decoration: InputDecoration(
//                       labelText: "Password",
//                       border: const OutlineInputBorder(),
//                       prefixIcon: const Icon(Icons.lock),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "Please enter your password";
//                       }
//
//                       if (value.length < 6) {
//                         return "Password must be at least 6 characters";
//                       }
//
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 30),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _login,
//                       child: _isLoading
//                           ? const SizedBox(
//                         width: 22,
//                         height: 22,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                           : const Text("Login"),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
