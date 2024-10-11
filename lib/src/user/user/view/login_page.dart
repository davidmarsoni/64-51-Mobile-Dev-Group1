import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/src/user/user/controller/user_controller.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';

class LoginPage extends StatefulWidget {
  final bool isReauthentication;

  const LoginPage({super.key, this.isReauthentication = false});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserController _userController = UserController();

  User? _currentUser;
  bool _passwordVisible = false;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _currentUser = _userController.currentUser;
    if (widget.isReauthentication && _currentUser != null) {
      _emailController.text = _currentUser!.email!;
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
        User? user = await _userController.loginWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        setState(() {
          _currentUser = user;
        });
        if (!widget.isReauthentication) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful')),
          );
        }
        if (widget.isReauthentication) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      } on FirebaseAuthException catch (e) {
        String message = _userController.getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  void _logout() async {
    await _userController.logout();
    setState(() {
      _currentUser = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logout successful')),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  void _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email to reset password')),
      );
      return;
    }

    String? message = await _userController.resetPassword(_emailController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'An unknown error occurred.')),
    );
  }

  void _showResetPasswordDialog() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email to reset password')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: const Text('Are you sure you want to reset your password?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetPassword();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      isBottomNavBarEnabled: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isReauthentication ? 'Reauthentication' : 'Login',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.isReauthentication) ...[
              const SizedBox(height: 8),
              const Text(
                'For security reasons, please reauthenticate',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_currentUser != null && !widget.isReauthentication) ...[
              const SizedBox(height: 20),
              Text('You are already logged as: ${_currentUser!.email}',
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
            if (_currentUser == null || widget.isReauthentication) ...[
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
                                  Navigator.pushNamed(context, '/createAccount');
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
                        text: 'Login',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showResetPasswordDialog,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blue),
                        ),
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