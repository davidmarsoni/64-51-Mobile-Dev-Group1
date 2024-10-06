import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerController {
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
        return 'An unknown error occurred: ${e.message}';
    }
  }

  // Check if the user is an owner
  Future<bool> isOwner(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('owners').doc(uid).get();
      if (doc.exists) {
        return true;
      } else {
        print('No owner document found for uid: $uid');
      }
    } catch (e) {
      print('Error checking owner status: $e');
    }
    return false;
  }
}