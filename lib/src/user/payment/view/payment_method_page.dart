import 'package:flutter/material.dart';
import 'package:valais_roll/data/objects/payementData.dart';
import 'package:valais_roll/data/objects/payementMethod.dart';
import 'package:valais_roll/src/user/widgets/base_page.dart';
import 'package:valais_roll/src/user/payment/controller/payment_method_controller.dart';
import 'package:valais_roll/src/user/payment/view/payment_forms.dart'; // Make sure this import is present
import 'package:valais_roll/src/user/payment/view/payment_method_option.dart';
import 'package:valais_roll/src/widgets/button.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String? selectedPaymentMethod;
  String? currentViewedMethod; 
  String? creditCardNumber;
  bool isLoadingCreditCard = false;
  bool isLoadingGooglePay = false;
  bool isLoadingKlarna = false;
  bool isLoadingData = true;

  final PaymentMethodController _controller = PaymentMethodController();

  // Add a TextEditingController for the credit card number display
  final TextEditingController _creditCardController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethod();
  }

  // Fetch the payment method from the controller (Firestore)
  Future<void> _fetchPaymentMethod() async {
    selectedPaymentMethod = await _controller.fetchPaymentMethod();
    if (selectedPaymentMethod == PaymentMethod.creditCard.name) {
      creditCardNumber = await _controller.fetchCreditCardNumber();
      if (creditCardNumber != null) {
        _creditCardController.text = _formatCreditCardNumber(creditCardNumber!); 
      }
    }
    setState(() {
      isLoadingData = false;
    });
  }

  // Update the payment method via the controller (Firestore)
  void _selectPaymentMethod(PaymentData payementData) async {
    await _controller.updatePaymentMethod(payementData);
    setState(() {
      selectedPaymentMethod = payementData.paymentMethod;
    });
  }

  // Opens the form without selecting the method
  void _viewPaymentMethod(String method) {
    setState(() {
      currentViewedMethod = method;
    });
  }

  // Delete the payment method
  void _deletePaymentMethod() async {
    _controller.deletePaymentMethod();
    setState(() {
      selectedPaymentMethod = null;
      currentViewedMethod = null;
      creditCardNumber = null;
      _creditCardController.clear(); // Clear the controller
    });
    // Show a snackbar or dialog to confirm the deletion
    _showSnackBar(context, 'Payment Method Deleted');
    // Navigate back to the account page pop the current page
    Navigator.pop(context);
  }

  // Method to show a snackbar
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete the payment method?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); 
                _deletePaymentMethod(); 
              },
            ),
          ],
        );
      },
    );
  }

  // When the user selects a payment method
  void _confirmGooglePay() async {
    setState(() {
      isLoadingGooglePay = true;
    });

    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isLoadingGooglePay = false;
    });

    // Show the alert pop-up to confirm payment method
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Google Pay', textAlign: TextAlign.left),
          content: const Text('You have selected Google Pay as your payment method. \n\n'
              'With Google Pay, you will be redirected to Google Pay to complete the payment.', textAlign: TextAlign.left),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK', textAlign: TextAlign.left),
            ),
          ],
        );
      },
    );

    // After the dialog is closed, update the selected payment method and close the page
    _selectPaymentMethod(PaymentData(paymentMethod: PaymentMethod.googlePay.name));
    Navigator.pop(context);
  }

  void _confirmKlarnaPayment() async {
    setState(() {
      isLoadingKlarna = true;
    });

    await Future.delayed(const Duration(seconds: 7));
    setState(() {
      isLoadingKlarna = false;
    });

    // Show the alert pop-up to confirm payment method
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Klarna', textAlign: TextAlign.left),
          content: const Text('You have selected Klarna as your payment method. \n\n'
              'With Klarna, you will receive an invoice to your email address with the payment details.', textAlign: TextAlign.left),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK', textAlign: TextAlign.left),
            ),
          ],
        );
      },
    );

    // After the dialog is closed, update the selected payment method and close the page
    _selectPaymentMethod(PaymentData(paymentMethod: PaymentMethod.klarna.name));
    Navigator.pop(context);
  }

  void _confirmCreditCard(PaymentData payementData) async {
    setState(() {
      isLoadingCreditCard = true;
    });

    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isLoadingCreditCard = false;
    });

    // Show the alert pop-up to confirm payment method
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Credit Card', textAlign: TextAlign.left),
          content: const Text('You have selected the Credit Card as your payment method. \n\n'
              'With Credit Card, you will be able to pay with your credit card.', textAlign: TextAlign.left),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK', textAlign: TextAlign.left),
            ),
          ],
        );
      },
    );

    // After the dialog is closed, update the selected payment method and close the page
    payementData.paymentMethod = PaymentMethod.creditCard.name;
    _selectPaymentMethod( payementData);
    Navigator.pop(context);
  }

  // Format the credit card number to have a space every 4 digits
  String _formatCreditCardNumber(String number) {
    String cleanedNumber = number.replaceAll(RegExp(r'\s+'), ''); // Remove any existing spaces
    String formatted = '';
    for (int i = 0; i < cleanedNumber.length; i++) {
      if (i % 4 == 0 && i != 0) {
        formatted += ' ';
      }
      formatted += cleanedNumber[i];
    }
    return formatted;
  }

  // A reusable padding widget for all the options
  Widget paddedContent(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,  // Adjust left padding
        top: 10.0,   // Adjust top padding
        right: 20.0, // Adjust right padding
        bottom: 10.0 // Adjust bottom padding
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Payment Methods',
      isBottomNavBarEnabled: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select a Payment Method:',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20),

                    // Credit Card Payment Option
                    PaymentOption(
                      title: 'Credit Card',
                      pngPath: 'assets/png/mastercard.png',
                      onSelect: () => _viewPaymentMethod('Credit Card'),
                      isSelected: selectedPaymentMethod == PaymentMethod.creditCard.name,
                      isViewing: currentViewedMethod == 'Credit Card',
                      child: currentViewedMethod == 'Credit Card'
                          ? (selectedPaymentMethod == PaymentMethod.creditCard.name
                              ? paddedContent(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('You have selected the Credit Card with the number:', textAlign: TextAlign.left),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _creditCardController,
                                        readOnly: true, 
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : paddedContent(
                                  CreditCardForm(
                                    onConfirm: _confirmCreditCard,
                                    isLoading: isLoadingCreditCard,
                                  )))
                          : null,
                    ),

                    const SizedBox(height: 20),

                    // Google Pay Payment Option
                    PaymentOption(
                      title: 'Google Pay',
                      pngPath: 'assets/png/googlePay.png',
                      onSelect: () => _viewPaymentMethod('Google Pay'),
                      isSelected: selectedPaymentMethod ==  PaymentMethod.googlePay.name,
                      isViewing: currentViewedMethod == 'Google Pay',
                      child: currentViewedMethod == 'Google Pay'
                          ? (selectedPaymentMethod == PaymentMethod.googlePay.name
                              ? paddedContent(
                                  const Text('You have selected Google Pay as your payment method. You will now be redirected to complete your payment. For more information, please contact Google Pay.', textAlign: TextAlign.left))
                              : paddedContent(
                                  GooglePayForm(
                                    onConfirm: _confirmGooglePay,
                                    isLoading: isLoadingGooglePay,
                                  )))
                          : null,
                    ),

                    const SizedBox(height: 20),

                    // Klarna Payment Option
                    PaymentOption(
                      title: 'Klarna (Facturing)',
                      pngPath: 'assets/png/klarna.png',
                      onSelect: () => _viewPaymentMethod('Facturing (Klarna)'),
                      isSelected: selectedPaymentMethod == PaymentMethod.klarna.name,
                      isViewing: currentViewedMethod == 'Facturing (Klarna)',
                      child: currentViewedMethod == 'Facturing (Klarna)'
                          ? (selectedPaymentMethod == PaymentMethod.klarna.name
                              ? paddedContent(
                                  const Text(
                                    'You have selected Klarna as your payment method. An invoice with the payment details will be sent to your email address. For more information, please contact Klarna.',
                                    textAlign: TextAlign.left,
                                  ))
                              : paddedContent(
                                  FacturingForm(
                                    onConfirm: _confirmKlarnaPayment,
                                    isLoading: isLoadingKlarna,
                                  )))
                          : null,
                    ),

                    // Delete Payment Method Button
                    const SizedBox(height: 30),
                    Button(
                      text: 'Delete payment method',
                      onPressed: _showDeleteConfirmationDialog,
                      isFilled: true,
                      horizontalPadding: 20.0,
                      verticalPadding: 20,
                      color: const Color.fromARGB(255, 192, 18, 6),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}