import 'package:flutter/material.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}