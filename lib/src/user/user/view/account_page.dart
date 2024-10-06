import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valais_roll/data/objects/appUser.dart';
import 'package:valais_roll/src/user/user/controller/user_controller.dart';
import 'package:valais_roll/src/user/welcome/welcome_page.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final UserController _userController = UserController();
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'email': TextEditingController(),
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

  final Map<String, FocusNode> _focusNodes = {
    'email': FocusNode(),
    'name': FocusNode(),
    'surname': FocusNode(),
    'phone': FocusNode(),
    'birthDate': FocusNode(),
    'username': FocusNode(),
    'address': FocusNode(),
    'number': FocusNode(),
    'npa': FocusNode(),
    'locality': FocusNode(),
  };

  final Map<String, bool> _isEditing = {
    'email': false,
    'name': false,
    'surname': false,
    'phone': false,
    'birthDate': false,
    'username': false,
    'address': false,
    'number': false,
    'npa': false,
    'locality': false,
  };

  late AppUser _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _focusNodes.forEach((key, focusNode) {
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          setState(() {
            _isEditing[key] = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNodes.forEach((key, focusNode) {
      focusNode.dispose();
    });
    super.dispose();
  }

  Future<void> _loadUserData() async {
    User? user = _userController.currentUser;
    if (user != null) {
      AppUser? appUser = await _userController.getUserFromFirestore(user.uid);
      print(appUser);
      if (appUser != null) {
        setState(() {
          _currentUser = appUser;
          _controllers['email']!.text = user.email!;
          _controllers['name']!.text = appUser.name;
          _controllers['surname']!.text = appUser.surname;
          _controllers['phone']!.text = appUser.phone;
          _controllers['birthDate']!.text = appUser.birthDate;
          _controllers['username']!.text = appUser.username;
          _controllers['address']!.text = appUser.address;
          _controllers['number']!.text = appUser.number;
          _controllers['npa']!.text = appUser.npa;
          _controllers['locality']!.text = appUser.locality;
        });
      }
    }
  }

  void _toggleEditing(String field) {
    setState(() {
      _isEditing[field] = !_isEditing[field]!;
    });
  }

  void _saveChanges(String field) async {
    if (_formKey.currentState!.validate()) {
      String? validationMessage = _userController.validateField(_controllers[field]!.text, field);
      
      if (validationMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationMessage)),
        );
        return;
      }

      if (field == 'email') {
        await _changeEmail();
      } else {
        AppUser updatedUser = AppUser(
          uid: _currentUser.uid,
          email: '', // Email cannot be updated with the firestore update method
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

        await _userController.updateUserInFirestore(updatedUser);
        setState(() {
          _currentUser = updatedUser;
          _isEditing[field] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Information updated successfully')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Increase width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureNewPassword,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: obscureConfirmPassword,
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildPasswordCriteria(newPasswordController.text),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newPasswordController.text == confirmPasswordController.text) {
                  try {
                    await _userController.changePassword(context, newPasswordController.text);
                    Navigator.pop(context); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password changed successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                }
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
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

    Future<void> _changeEmail() async {
    if (_formKey.currentState!.validate()) {
      String? validationMessage = _userController.validateField('email', _controllers['email']!.text);
      if (validationMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationMessage)),
        );
        return;
      }
  
      try {
        String message = await _userController.changeEmail(context, _controllers['email']!.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _controllers['birthDate']!.text = DateFormat('dd.MM.yyyy').format(picked);
        _isEditing['birthDate'] = true;
      });
    }
  }

  Future<void> _logout() async {
    await _userController.logout();
    // Redirect to welcome page
   Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => WelcomePage()),
      (Route<dynamic> route) => false,
    );
  }

 Future<void> _deleteAccount() async {
  bool confirmed = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Account'),
      content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

    if (confirmed) {
      try {
        await _userController.deleteUser(context);
        Navigator.of(context).pushReplacementNamed('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildTextField(String label, String controllerKey) {
    return TextFormField(
      controller: _controllers[controllerKey],
      focusNode: _focusNodes[controllerKey],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: _isEditing[controllerKey]!
            ? IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _saveChanges(controllerKey),
              )
            : IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _toggleEditing(controllerKey),
              ),
      ),
      readOnly: controllerKey != 'email' && !_isEditing[controllerKey]!,
      onTap: controllerKey == 'birthDate' && !_isEditing[controllerKey]!
          ? () => _selectDate(context)
          : null,
      validator: (value) {
        String? validationMessage = _userController.validateField(controllerKey, value!);
        if (validationMessage != null) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                  const Text('Personal Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildTextField('Name', 'name'),
                const SizedBox(height: 10),
                _buildTextField('Surname', 'surname'),
                const SizedBox(height: 10),
                _buildTextField('Phone', 'phone'),
                const SizedBox(height: 10),
                _buildTextField('Birth Date', 'birthDate'),
                const SizedBox(height: 20),

                const Text('Account Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildTextField('Email', 'email'),
                const SizedBox(height: 10),
                _buildTextField('Username', 'username'),
                const SizedBox(height: 10),
                Button(
                  onPressed: _changePassword,
                  text: 'Change Password',
                  isFilled: false,
                  horizontalPadding: 20,
                ),
                const SizedBox(height: 20),

                const Text('Address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildTextField('Address', 'address'),
                const SizedBox(height: 10),
                _buildTextField('Adress number', 'number'),
                const SizedBox(height: 10),
                _buildTextField('NPA', 'npa'),
                const SizedBox(height: 10),
                _buildTextField('Locality', 'locality'),
                const SizedBox(height: 20),

                const Text('Account Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Button(
                  onPressed: _logout,
                  text: 'Logout',
                  isFilled: false,
                  horizontalPadding: 20,
                ),
                const SizedBox(height: 20),

                const Text('Danger Zone', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 10),
                Button(
                  onPressed: _deleteAccount,
                  text: 'Delete Account',
                  isFilled: true,
                  horizontalPadding: 20,
                  color: const Color.fromARGB(255, 192, 18, 6),
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