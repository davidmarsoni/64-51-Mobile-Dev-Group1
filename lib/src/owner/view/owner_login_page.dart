import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/src/owner/controller/owner_controller.dart';
import 'package:valais_roll/src/owner/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';

class OwnerLoginPage extends StatefulWidget {
  const OwnerLoginPage({super.key});

  @override
  _OwnerLoginPageState createState() => _OwnerLoginPageState();
}

class _OwnerLoginPageState extends State<OwnerLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final OwnerController _ownerController = OwnerController();
  
  User? _currentUser;
  bool _passwordVisible = false;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _currentUser = _ownerController.currentUser;
    if (_currentUser != null) {
      _checkOwnerStatusAndNavigate(_currentUser!.uid);
    }
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
        User? user = await _ownerController.loginWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        if (user != null) {
          bool isOwner = await _ownerController.isOwner(user.uid);
          if (isOwner) {
            setState(() {
              _currentUser = user;
            });
            _navigateToDashboard();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You do not have access to this area.')),
            );
            await _ownerController.logout();
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = _ownerController.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  void _checkOwnerStatusAndNavigate(String uid) async {
    bool isOwner = await _ownerController.isOwner(uid);
    if (isOwner) {
      _navigateToDashboard();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have access to this area.')),
      );
      await _ownerController.logout();
    }
  }

  void _navigateToDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful')),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/owner_dashboard', (route) => false);
  }

  void _logout() async {
    await _ownerController.logout();
    setState(() {
      _currentUser = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logout successful')),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/owner_login', (route) => false);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Owner Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (_currentUser != null) ...[
              const SizedBox(height: 20),
              Text('You are already logged in as: ${_currentUser!.email}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Button(
                  onPressed: _logout,
                  text: 'Logout',
                  isFilled: false,
                ),
              ),
            ],
            if (_currentUser == null) ...[
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
                      autofillHints: const [AutofillHints.email],
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
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Button(
                        onPressed: _loginWithEmail,
                        text: 'Login',
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