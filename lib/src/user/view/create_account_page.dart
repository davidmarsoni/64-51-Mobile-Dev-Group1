import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/appUser.dart';
import 'package:valais_roll/src/others/privacy_policy_page.dart';
import 'package:valais_roll/src/user/controller/user_controller.dart';
import 'package:valais_roll/src/widgets/button.dart';
import 'package:valais_roll/src/widgets/base_page.dart';
import 'package:intl/intl.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final UserController _userController = UserController();
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
  bool _confirmPasswordVisible = false;
  bool _acceptPrivacyPolicy = false;
  final Map<String, String?> _errors = {};

  Widget _buildBirthDateField() {
    return TextFormField(
      controller: _controllers['birthDate'],
      decoration: const InputDecoration(
        labelText: 'Birth Date',
        border: OutlineInputBorder(),
      ),
      readOnly: true, // Prevent manual text input
      onTap: () {
        _selectBirthDate(context); // Open date picker on tap
      },
      validator: (value) => _userController.validateField(value!, 'birthDate'),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final DateFormat formatter = DateFormat('dd.MM.yyyy');
      final String formatted = formatter.format(picked);
      _controllers['birthDate']?.text = formatted;
    }
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
      // Validate all fields
      _errors.clear();
      _controllers.forEach((key, controller) {
        _errors[key] = _userController.validateField(controller.text, key);
      });

      // Check if passwords match
      if (_controllers['password']!.text != _controllers['confirmPassword']!.text) {
        _errors['confirmPassword'] = 'Passwords do not match';
      }
    });

    if (!_formKey.currentState!.validate() || _errors.values.any((error) => error != null) || !_acceptPrivacyPolicy) {
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
        uid: '', // Placeholder, will be set after account creation
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
      bool userExists = await _userController.checkUserByAddress(newUser.address, newUser.number, newUser.npa);

      if (userExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A user already exists with this address.')),
        );
        return;
      }

      // Create the account
      User? user = await _userController.createAccountWithEmail(newUser.email, _controllers['password']!.text);

      if (user != null) {
        // Send email verification
        if (!user.emailVerified) {
          await _userController.sendEmailVerification(user);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification email sent. Please check your email.')),
          );
        }

        // Set the UID in the AppUser object
        newUser = AppUser(
          uid: user.uid,
          email: newUser.email,
          name: newUser.name,
          surname: newUser.surname,
          phone: newUser.phone,
          birthDate: newUser.birthDate,
          username: newUser.username,
          address: newUser.address,
          number: newUser.number,
          npa: newUser.npa,
          locality: newUser.locality,
        );

        // Add the user to Firestore
        await _userController.addUserToFirestore(user, newUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!, you are now logged in.')),
        );

        //redirect to home page
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String message = _userController.getErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  Widget _buildTextField(String label, String controllerKey, {bool obscureText = false, TextInputType keyboardType = TextInputType.text, Iterable<String>? autofillHints}) {
    return TextFormField(
      controller: _controllers[controllerKey],
      decoration: InputDecoration(
        labelText: label,
        errorText: _errors[controllerKey],
        border: const OutlineInputBorder(),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(controllerKey == 'password' ? (_passwordVisible ? Icons.visibility : Icons.visibility_off) : (_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off)),
                onPressed: () {
                  setState(() {
                    if (controllerKey == 'password') {
                      _passwordVisible = !_passwordVisible;
                    } else {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    }
                  });
                },
              )
            : null,
      ),
      obscureText: obscureText && (controllerKey == 'password' ? !_passwordVisible : !_confirmPasswordVisible),
      keyboardType: keyboardType,
      validator: (value) => _userController.validateField(value!, controllerKey),
      onChanged: (value) {
        setState(() {
          _errors[controllerKey] = _userController.validateField(value, controllerKey);
        });
      },
      autofillHints: autofillHints,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Create Account',
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
                _buildTextField('Username', 'username', autofillHints: [AutofillHints.username]),
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
                _buildTextField('Email', 'email', keyboardType: TextInputType.emailAddress, autofillHints: [AutofillHints.email]),
                const SizedBox(height: 16),
                _buildTextField('Password', 'password', obscureText: true, autofillHints: [AutofillHints.newPassword]),
                const SizedBox(height: 16),
                _buildTextField('Confirm Password', 'confirmPassword', obscureText: true, autofillHints: [AutofillHints.newPassword]),
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
      isBottomNavBarEnabled: false,
    );
  }
}