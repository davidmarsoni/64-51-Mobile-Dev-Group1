import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/appUser.dart';
import 'package:valais_roll/src/others/privacy_policy_page.dart';
import 'package:valais_roll/src/services/auth_service.dart';
import 'package:valais_roll/src/widgets/button.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/top_bar.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

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

  bool _passwordVisible = false;
  bool _acceptPrivacyPolicy = false;
  String? passwordError;
  String? confirmPasswordError;

  String? _validateField(String value, String fieldType) {
    if (value.isEmpty) return 'This field cannot be empty.';
    
    // Email validation
    if (fieldType == 'email' && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    
    // Phone validation (only digits)
    if (fieldType == 'phone' && !RegExp(r'^\d+$').hasMatch(value)) {
      return 'Please enter a valid phone number.';
    }

    // NPA validation (only digits)
    if (fieldType == 'npa' && !RegExp(r'^\d+$').hasMatch(value)) {
      return 'Please enter a valid NPA.';
    }

    // Number validation (only digits)
    if (fieldType == 'number' && !RegExp(r'^\d+$').hasMatch(value)) {
      return 'Please enter a valid road number.';
    }
    
    // Password validation
    if (fieldType == 'password') {
      if (value.length < 8) return 'Password must be at least 8 characters long.';
      if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password must contain at least one uppercase letter.';
      if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password must contain at least one lowercase letter.';
      if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must contain at least one digit.';
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return 'Password must contain at least one special character.';
    }

    // Confirm password validation
    if (fieldType == 'confirmPassword' && value != _controllers['password']!.text) {
      return 'Passwords do not match.';
    }

    // Name, surname, and username validation
    if (['name', 'surname', 'username'].contains(fieldType) && value.length < 2) {
      return 'This field must be at least 2 characters long.';
    }

    // Birthdate validation (simple format check)
    if (fieldType == 'birthDate' && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return 'Please enter a valid birth date (YYYY-MM-DD).';
    }

    // Address validation (not empty)
    if (fieldType == 'address' && value.isEmpty) {
      return 'Address cannot be empty.';
    }

    // Locality validation
    if (fieldType == 'locality' && value.isEmpty) {
      return 'Locality cannot be empty.';
    }

    return null;
  }


  void _selectBirthDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _controllers['birthDate']!.text = "${pickedDate.toLocal()}".split(' ')[0];  // Formatting the date as YYYY-MM-DD
      });
    }
  }

  Widget _buildBirthDateField() {
    return TextFormField(
      controller: _controllers['birthDate'],
      decoration: const InputDecoration(
        labelText: 'Birth Date',
        border: OutlineInputBorder(),
      ),
      readOnly: true,  // Prevent manual text input
      onTap: () {
        _selectBirthDate(context);  // Open date picker on tap
      },
      validator: (value) => _validateField(value!, 'birthDate'),
    );
  }

  List<Widget> _buildPasswordCriteria(String password) {
    return [
      const Text('Password must contain:', style: TextStyle(fontWeight: FontWeight.bold)),
      _buildCriteriaItem('At least 8 characters', password.length >= 8),
      _buildCriteriaItem('At least one uppercase letter', RegExp(r'[A-Z]').hasMatch(password)),
      _buildCriteriaItem('At least one lowercase letter', RegExp(r'[a-z]').hasMatch(password)),
      _buildCriteriaItem('At least one digit', RegExp(r'[0-9]').hasMatch(password)),
      _buildCriteriaItem('At least one special character', RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)),
    ];
  }

  Widget _buildCriteriaItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(isValid ? Icons.check : Icons.close, color: isValid ? Colors.green : Colors.red),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  void _createAccount() async {
    setState(() {
      // Validate confirm password and password
      confirmPasswordError = _validateField(_controllers['confirmPassword']!.text, 'confirmPassword');
      passwordError = _validateField(_controllers['password']!.text, 'password');
    });

    if (!_formKey.currentState!.validate() || passwordError != null || confirmPasswordError != null || !_acceptPrivacyPolicy) {
      if (!_acceptPrivacyPolicy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must accept the privacy policy to continue.')),
        );
      }
      return;
    }

    try {
      // Create the AppUser object with form data
      AppUser newUser = AppUser(
        email: _controllers['email']!.text,
        name: _controllers['name']!.text,
        surname: _controllers['surname']!.text,
        phone: _controllers['phone']!.text,
        birthDate: _controllers['birthDate']!.text,
        username: _controllers['username']!.text,
        address: _controllers['address']!.text,
        number: _controllers['number']!.text,
        npa: _controllers['npa']!.text,
        locality: _controllers['locality']!.text,
      );

      // Check if a user already exists with this address
      bool userExists = await _authService.checkUserByAddress(newUser.address, newUser.number, newUser.npa);

      if (userExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A user already exists with this address.')),
        );
        return;
      }

      // Create the account
      User? user = await _authService.createAccountWithEmail(newUser.email, _controllers['password']!.text);

      if (user != null) {
        // Send email verification
        if (!user.emailVerified) {
          await _authService.sendEmailVerification(user);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification email sent. Please check your email.')),
          );
        }

        // Add the user to Firestore
        await _authService.addUserToFirestore(user, newUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! Please verify your email.')),
        );
      }
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

  Widget _buildTextField(String label, String controllerKey, {bool obscureText = false, TextInputType keyboardType = TextInputType.text, String? errorText}) {
    return TextFormField(
      controller: _controllers[controllerKey],
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        border: const OutlineInputBorder(),
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
      validator: (value) => _validateField(value!, controllerKey),
      onChanged: (value) {
        setState(() {});
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Create your account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Personal Information Section
                const Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildTextField('Name', 'name'),
                const SizedBox(height: 10),
                _buildTextField('Surname', 'surname'),
                const SizedBox(height: 10),
                _buildTextField('Phone', 'phone', keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _buildBirthDateField(),
                const SizedBox(height: 20),

                // Avatar Section
                const Text('Avatar and Username', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildTextField('Username', 'username'),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: () {}, child: const Text('Upload Avatar Picture')),
                const SizedBox(height: 20),

                // Address Section
                const Text('Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2, // This ensures the "Address" field fills more space
                      child: _buildTextField('Address', 'address'),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100, // Adjust the width to fit the "Number" field
                      child: _buildTextField('Number', 'number', keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 100, // Adjust the width to fit the "NPA" field
                      child: _buildTextField('NPA', 'npa', keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2, // This ensures the "Locality" field fills the remaining space
                      child: _buildTextField('Locality', 'locality'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Account Section
                const Text('Account Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildTextField('Email', 'email', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField('Password', 'password', obscureText: true, errorText: passwordError),
                const SizedBox(height: 16),
                _buildTextField('Confirm Password', 'confirmPassword', obscureText: true, errorText: confirmPasswordError),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildPasswordCriteria(_controllers['password']!.text)),
                ),
                const SizedBox(height: 20),

                // Privacy Policy
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
                      child: RichText(
                        text: TextSpan(
                          text: 'I accept the ',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'privacy policy',
                              style: const TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Create Account Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Button(
                    onPressed: _createAccount,
                    text: 'Create Account',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(isEnabled: false),
    );
  }
}