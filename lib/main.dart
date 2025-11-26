import 'package:flutter/material.dart';

// Screen imports
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DummyJSONApp());
}

class DummyJSONApp extends StatelessWidget {
  const DummyJSONApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DummyJSON User Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      // Initial route when app starts
      initialRoute: Routes.home,
      // All app routes defined here
      routes: {
        Routes.home: (context) => const HomeScreen(),
        Routes.signup: (context) => const SignupScreen(),
      },
    );
  }
}

/// Centralized route definitions for the app
/// 
/// For better architecture, consider moving this to a separate file:
/// lib/core/routes.dart
class Routes {
  static const String home = '/home';
  static const String signup = '/signup';
}