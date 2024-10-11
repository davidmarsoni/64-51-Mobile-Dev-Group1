import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valais_roll/data/objects/payement_data.dart';

class PaymentMethodController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch payment method from Firestore
  Future<String?> fetchPaymentMethod() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic>? paymentData = userDoc['payment_data'] as Map<String, dynamic>?;
          if (paymentData == null) {
            await _initializePaymentData(user.uid);
            return null;
          }
          return paymentData['payment_method'] as String?;
          
        }
      } catch (e) {
        //create payment data if it doesn't exist
        await _initializePaymentData(user.uid);
      }
    }
    return null;
  }

  // Fetch credit card number from Firestore
  Future<String?> fetchCreditCardNumber() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic>? paymentData = userDoc['payment_data'] as Map<String, dynamic>?;
          if (paymentData == null) {
            await _initializePaymentData(user.uid);
            return null;
          }
          return paymentData['card_number'] as String?;
        }
      } catch (e) {
        print('Error fetching credit card number: $e');
      }
    }
    return null;
  }

  Future<String?> fetchCreditCardExpiryDate() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic>? paymentData = userDoc['payment_data'] as Map<String, dynamic>?;
          if (paymentData == null) {
            await _initializePaymentData(user.uid);
            return null;
          }
          return paymentData['expiration_date'] as String?;
        }
      } catch (e) {
        print('Error fetching credit card expiry date: $e');
      }
    }
    return null;
  }

  Future<void> deletePaymentMethod() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'payment_data': PaymentData(
            cardNumber: '',
            expirationDate: '',
            cardOwner: '',
            cvv: '',
            paymentMethod: 'none',
          ).toMap(),
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error deleting payment method: $e');
      }
    }
  }

  // Update payment method with PaymentData object
  Future<void> updatePaymentMethod(PaymentData paymentData) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'payment_data': paymentData.toMap(),
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error updating payment method: $e');
      }
    }
  }

  // Initialize payment data if it doesn't exist
  Future<void> _initializePaymentData(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'payment_data': PaymentData(
          cardNumber: '',
          expirationDate: '',
          cardOwner: '',
          cvv: '',
          paymentMethod: 'none',
        ).toMap(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error initializing payment data: $e');
    }
  }
}