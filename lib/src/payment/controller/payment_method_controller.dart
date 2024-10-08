import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentMethodController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch payment method from Firestore
  Future<String?> fetchPaymentMethod() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.exists && userDoc.data() != null ? userDoc['payment_method'] as String? : null;
    }
    return null;
  }

  // Fetch credit card number from Firestore
  Future<String?> fetchCreditCardNumber() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.exists && userDoc.data() != null ? userDoc['credit_card_number'] as String? : null;
    }
    return null;
  }

  Future<String?> fetchCreditCardExpiryDate() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.exists && userDoc.data() != null ? userDoc['expiry_date'] as String? : null;
    }
    return null;
  }

  Future<void> deletePaymentMethod() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'payment_method': 'none',
        'credit_card_number': null,
      }, SetOptions(merge: true));
      
    }
  }

  // Update payment method and optionally credit card
  Future<void> updatePaymentMethod(String method, [String? maskedCard]) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'payment_method': method,
        if (maskedCard != null) 'credit_card_number': maskedCard, // Save masked card if provided
      }, SetOptions(merge: true));
    }
  }
}
