// // screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:project/screens/signup_screen.dart';
import '../models/auth_model.dart';
import '../services/api_service.dart';
import 'users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _loginMessage;
  bool _isLoginSuccess = false;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _isLoginSuccess = false;
        _loginMessage = '❌ Please enter username and password';
      });
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _loginMessage = null;
    });

    try {
      final loginRequest = LoginRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final response = await _apiService.login(loginRequest);

      setState(() {
        _isLoginSuccess = true;
        _loginMessage =
            '✅ Login successful!\nWelcome, ${response.firstName} ${response.lastName}';
        _isLoggingIn = false;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UsersScreen(token: response.accessToken),
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoginSuccess = false;
        _loginMessage = '❌ Login failed: Invalid credentials';
        _isLoggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DummyJSON Login'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '🔐 User Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'e.g. emilys',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'e.g. emilyspass',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoggingIn ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoggingIn
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text(
                              'LOGIN!',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                  
                  // ✅ লগইন মেসেজ (সফল/ব্যর্থ) - শর্তহীন
                  if (_loginMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isLoginSuccess
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isLoginSuccess ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Text(
                        _loginMessage!,
                        style: TextStyle(
                          color: _isLoginSuccess
                              ? Colors.green[900]
                              : Colors.red[900],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  // ✅ সাইনআপ বাটন - শুধু লগইন সফল না হলে দেখাবে
                  if (!_isLoginSuccess && !_isLoggingIn) ...[
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[700]),
                          children: const [
                            TextSpan(
                              text: 'SIGNUP',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}