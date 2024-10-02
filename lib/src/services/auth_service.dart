import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valais_roll/data/objects/appUser.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Login with email and password
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
}