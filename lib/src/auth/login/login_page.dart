import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/src/auth/create_account/create_account_page.dart';
import 'package:valais_roll/src/services/auth_service.dart';
import 'package:valais_roll/src/widgets/base_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginWithEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = await _authService.loginWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        setState(() {
          _currentUser = user;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
      } on FirebaseAuthException catch (e) {
        String message = _authService.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  void _logout() async {
    await _authService.logout();
    setState(() {
      _currentUser = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logout successful')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Login Page',
      isBottomNavBarEnabled: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Section to display the current user
            if (_currentUser != null)
              Text('Current User: ${_currentUser!.email}',
                  style: const TextStyle(fontSize: 18)),
            if (_currentUser == null)
              const Text('No user connected', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_passwordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loginWithEmail,
                    child: const Text('Login with Email'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateAccountPage()),
                      );
                    },
                    child: const Text('Create Account'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}