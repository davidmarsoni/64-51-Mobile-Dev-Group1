import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/src/others/privacy_policy_page.dart';
import 'package:valais_roll/src/services/auth_service.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/top_bar.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final AuthService _authService = AuthService();
  final Map<String, TextEditingController> _controllers = {
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
    'name': TextEditingController(),
    'surname': TextEditingController(),
    'phone': TextEditingController(),
    'birthDate': TextEditingController(),
    'username': TextEditingController(),
    'address': TextEditingController(),
    'number': TextEditingController(),
    'npa': TextEditingController(),
    'locality': TextEditingController(),
  };

  String? passwordError;
  String? confirmPasswordError;
  bool _passwordVisible = false;
  bool _acceptPrivacyPolicy = false;

  void _createAccount() async {
    setState(() {
      confirmPasswordError = _validateConfirmPassword(_controllers['password']!.text, _controllers['confirmPassword']!.text);
      passwordError = _validatePassword(_controllers['password']!.text);
    });

    if (passwordError != null || confirmPasswordError != null || !_acceptPrivacyPolicy) {
      if (!_acceptPrivacyPolicy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must accept the privacy policy to continue.')),
        );
      }
      return;
    }

    try {
      User? user = await _authService.createAccountWithEmail(
        _controllers['email']!.text,
        _controllers['password']!.text,
      );

      if (user != null && !user.emailVerified) {
        await _authService.sendEmailVerification(user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent. Please check your email.')),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully! Please verify your email.')),
      );
    } on FirebaseAuthException catch (e) {
      String message = _authService.getErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password cannot be empty.';
    if (password.length < 8) return 'Password must be at least 8 characters long.';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Password must contain at least one uppercase letter.';
    if (!RegExp(r'[a-z]').hasMatch(password)) return 'Password must contain at least one lowercase letter.';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Password must contain at least one digit.';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return 'Password must contain at least one special character.';
    return null;
  }

  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return 'Confirm Password cannot be empty.';
    if (password != confirmPassword) return 'Passwords do not match.';
    return null;
  }

  List<Widget> _buildPasswordCriteria(String password) {
    final criteria = [
      {'text': 'At least 8 characters', 'regex': r'.{8,}'},
      {'text': 'An uppercase letter', 'regex': r'[A-Z]'},
      {'text': 'A lowercase letter', 'regex': r'[a-z]'},
      {'text': 'A digit', 'regex': r'[0-9]'},
      {'text': 'A special character', 'regex': r'[!@#$%^&*(),.?":{}|<>]'},
    ];

    return criteria.map((criterion) {
      final isValid = RegExp(criterion['regex']!).hasMatch(password);
      return Row(
        children: [
          Icon(isValid ? Icons.check : Icons.close, color: isValid ? Colors.green : Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(criterion['text']!, style: TextStyle(color: isValid ? Colors.green : Colors.red)),
        ],
      );
    }).toList();
  }

  Widget _buildTextField(String label, String controllerKey, {bool obscureText = false, String? errorText, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: _controllers[controllerKey],
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              )
            : null,
      ),
      obscureText: obscureText && !_passwordVisible,
      keyboardType: keyboardType,
      onChanged: (value) {
        if (controllerKey == 'password') {
          setState(() {
            passwordError = _validatePassword(value);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'ValaisRoll'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Align(alignment: Alignment.centerLeft, child: Text('Create your account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              const Align(alignment: Alignment.centerLeft, child: Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              _buildTextField('Name', 'name'),
              const SizedBox(height: 10),
              _buildTextField('Surname', 'surname'),
              const SizedBox(height: 10),
              _buildTextField('Phone', 'phone', keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildTextField('Birth Date', 'birthDate', keyboardType: TextInputType.datetime),
              const SizedBox(height: 20),
              const Align(alignment: Alignment.centerLeft, child: Text('Avatar and Username', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              _buildTextField('Username', 'username'),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () {}, child: const Text('Upload Avatar Picture')),
              const SizedBox(height: 20),
              const Align(alignment: Alignment.centerLeft, child: Text('Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              _buildTextField('Address', 'address'),
              const SizedBox(height: 10),
              _buildTextField('Number', 'number'),
              const SizedBox(height: 10),
              _buildTextField('NPA', 'npa'),
              const SizedBox(height: 10),
              _buildTextField('Locality', 'locality'),
              const SizedBox(height: 20),
              const Align(alignment: Alignment.centerLeft, child: Text('Account Related Stuff', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              _buildTextField('Email', 'email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField('Password', 'password', obscureText: true, errorText: passwordError),
              const SizedBox(height: 16),
              _buildTextField('Confirm Password', 'confirmPassword', obscureText: true, errorText: confirmPasswordError),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildPasswordCriteria(_controllers['password']!.text)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _acceptPrivacyPolicy,
                    onChanged: (value) {
                      setState(() {
                        _acceptPrivacyPolicy = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
                      },
                      child: const Text(
                        'I accept the privacy policy',
                        style: TextStyle(fontSize: 16, decoration: TextDecoration.underline, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _createAccount, child: const Text('Create Account')),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(isEnabled: false),
    );
  }
}