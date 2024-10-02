import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/src/auth/create_account/create_account_page.dart';
import 'package:valais_roll/src/services/auth_service.dart';
import 'package:valais_roll/src/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';

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
  String? passwordError;

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

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Login Page',
      isBottomNavBarEnabled: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
             if(_currentUser != null) ...[
                   const SizedBox(height: 20),
                   Text('You are already logged as: ${_currentUser!.email}',
                  style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8), 
                   Align(
                     alignment: Alignment.centerLeft,
                     child: Button(
                       onPressed: _logout,
                       text:'Logout',
                       isFilled: false,
                     ),
                   ),
             ],
            if (_currentUser == null) ...[
              const Text('No user connected', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: [AutofillHints.email],
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
                      errorText: passwordError,
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
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
                    onChanged: (value) {
                      if (_passwordController.text.isNotEmpty) {
                        setState(() {
                          passwordError = _validatePassword(value);
                        });
                      }
                    },
                  ),
                   Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: RichText(
                      textAlign: TextAlign.left, 
                      text: TextSpan(
                        text: "If you don't have an account yet, please create your account ",
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'here',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateAccountPage(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Button(
                     
                      onPressed: _loginWithEmail,
                      text:'Login',
                    ),
                  ),   
                ],
              ),
            ),
            ],
          ],
        ),
      ),
    );
  }
}