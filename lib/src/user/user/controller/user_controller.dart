import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/app_user.dart';
import 'package:valais_roll/src/user/user/view/login_page.dart'; 

class UserController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> loginWithEmail(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Create account with email and password
  Future<User?> createAccountWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User created: ${result.user!.uid}');
      return result.user;
    } catch (e) {
      throw FirebaseAuthException(
        message: 'Error creating account: ${e.toString()}',
        code: 'create-account-error',
      );
    }
  }

  // Send email verification
  Future<void> sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  // Check if the user already exists at the given address
  Future<bool> checkUserByAddress(String address, String number, String npa) async {
    QuerySnapshot query = await _firestore
        .collection('users')
        .where('address', isEqualTo: address)
        .where('number', isEqualTo: number)
        .where('npa', isEqualTo: npa)
        .get(); 

    return query.docs.isNotEmpty; // Returns true if a user already exists
  }

  // Add user to Firestore
  Future<void> addUserToFirestore(User user, AppUser appUser) async {
    appUser = AppUser(
      uid: user.uid,
      name: appUser.name,
      surname: appUser.surname,
      phone: appUser.phone,
      birthDate: appUser.birthDate,
      username: appUser.username,
      address: appUser.address,
      number: appUser.number,
      npa: appUser.npa,
      locality: appUser.locality,
      email: appUser.email,
    );

    // Add the map for the payementMethod to the firebase


    await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
  }

  // Error handling
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'The email or password is invalid.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      default:
        return e.code;
    }
  }

  Future<AppUser?> getUserFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser(
          uid: doc['uid'],
          email: '',
          name: doc['name'],
          surname: doc['surname'],
          phone: doc['phone'],
          birthDate: doc['birthDate'],
          username: doc['username'],
          address: doc['address'],
          number: doc['number'],
          npa: doc['npa'],
          locality: doc['locality'],
        );
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  Future<void> updateUserInFirestore(AppUser updatedUser) async {
    try {
      await _firestore.collection('users').doc(updatedUser.uid).update({
        'name': updatedUser.name,
        'surname': updatedUser.surname,
        'phone': updatedUser.phone,
        'birthDate': updatedUser.birthDate,
        'username': updatedUser.username,
        'address': updatedUser.address,
        'number': updatedUser.number,
        'npa': updatedUser.npa,
        'locality': updatedUser.locality,
      });
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

   Future<void> changePassword(BuildContext context, String newPassword) async {
    User? user = _auth.currentUser;
  
    if (user != null) {
      try {
        
        // Always show reauthentication popup
        await _showReauthenticationPopup(context);
  
        // Attempt to update the password
        await user.updatePassword(newPassword);
  
        // Sign out and sign in with the new password
        await _auth.signOut();
  
        await _auth.signInWithEmailAndPassword(
          email: user.email!,
          password: newPassword,
        );
      
      } on FirebaseAuthException catch (e) {
        throw Exception('Failed to change password: ${e.message}');
      }
    } else {
      throw Exception('No user is currently signed in.');
    }
  }

  Future<String> changeEmail(BuildContext context, String newEmail) async {
    User? user = _auth.currentUser;
  
    if (user != null) {
      try {
        // Always show reauthentication popup
        await _showReauthenticationPopup(context);
  
        // Proceed to change the email after reauthentication
        await user.verifyBeforeUpdateEmail(newEmail);
  
        // Inform the user to verify their email
        String message = 'Email updated. Please verify your new email to continue. You will be signed out.';
  
        // Sign out the user
        await _auth.signOut();
  
        // Redirect to login page route
        Navigator.of(context).pushReplacementNamed('/login');
  
        return message;
      } on FirebaseAuthException catch (e) {
        throw Exception('Failed to change email: ${e.message}');
      }
    } else {
      throw Exception('No user is currently signed in.');
    }
  }
    
  
 

  String? validateField(String value, String fieldType) {
    if (value.isEmpty) {
      return 'This field cannot be empty.';
    }

    if (fieldType == 'email') {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        return 'Please enter a valid email address.';
      }
    } else if (fieldType == 'phone') {
      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
        return 'Please enter a valid phone number.';
      }
    } else if (fieldType == 'npa') {
      if (!RegExp(r'^\d{4}$').hasMatch(value)) {
        return 'Please enter a valid NPA.';
      }
    } else if (fieldType == 'number') {
      if (!RegExp(r'^\d{1,5}[a-zA-Z]{0,2}$').hasMatch(value)) {
        return 'Enter a valid address number (0-5 digits followed by optional 2 alphabetic characters)';
      }
    } else if (fieldType == 'password') {
      if (value.length < 8) return 'Password must be at least 8 characters long.';
      if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password must contain at least one uppercase letter.';
      if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password must contain at least one lowercase letter.';
      if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must contain at least one digit.';
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return 'Password must contain at least one special character.';
    } else if (['name', 'surname', 'username', 'address', 'locality'].contains(fieldType)) {
      if (fieldType == 'name' || fieldType == 'surname') {
        if (value.length < 2) {
          return '$fieldType must be at least 2 characters long';
        }
      }
    } else if (fieldType == 'birthDate') {
      if (!RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(value)) {
        return 'Please enter a valid birth date (dd.mm.yyyy).';
      }
    }

    return null;
  }

  Future<void> deleteUser(BuildContext context) async {
    User? user = _auth.currentUser;
    
    if (user != null) {
      try {
        // Delete the user's document from Firestore first
        await _firestore.collection('users').doc(user.uid).delete();
    
        // Attempt to delete the user account
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          // Show reauthentication popup
          await _showReauthenticationPopup(context);
    
          // Retry deleting the user after reauthentication
          try {
            await user.delete();
          } on FirebaseAuthException catch (e) {
            throw Exception('Failed to delete user after reauthentication: ${e.message}');
          }
        } else {
          throw Exception('Failed to delete user: ${e.message}');
        }
      }
    } else {
      throw Exception('No user is currently signed in.');
    }
  }

  Future<void> _showReauthenticationPopup(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(isReauthentication: true),
      ),
    );

    if (result == true) {
      // Reauthentication was successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reauthentication successful')),
      );
    } else {
      // Reauthentication failed or was canceled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reauthentication failed or canceled')),
      );
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent');
      return 'Password reset email sent';
    } on FirebaseAuthException catch (e) {
      debugPrint('Failed to send password reset email: ${e.message}');
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      }
      return getErrorMessage(e);
    } catch (e) {
      return 'An unknown error occurred.';
    }
  }
}