import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valais_roll/src/payment/controller/payment_method_controller.dart';
import 'package:valais_roll/src/payment/view/payment_forms.dart'; // Make sure this import is present
import 'package:valais_roll/src/payment/view/payment_method_option.dart';
import 'package:valais_roll/src/user/widgets/nav_bar.dart';
import 'package:valais_roll/src/user/widgets/top_bar.dart';

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
  TextEditingController _creditCardController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethod();
  }

  // Fetch the payment method from the controller (Firestore)
  Future<void> _fetchPaymentMethod() async {
    selectedPaymentMethod = await _controller.fetchPaymentMethod();
    if (selectedPaymentMethod == 'Credit Card') {
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
  void _selectPaymentMethod(String method, [String? maskedCard]) async {
    await _controller.updatePaymentMethod(method, maskedCard);
    setState(() {
      selectedPaymentMethod = method;
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
  }

  // Method to show a snackbar
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          title: const Text('Google Pay'),
          content: const Text('You have selected Google Pay as your payment method. \n\n'
              'With Google Pay, you will be redirected to Google Pay to complete the payment.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // After the dialog is closed, update the selected payment method and close the page
    _selectPaymentMethod('Google Pay');
    Navigator.pop(context, 'Google Pay');
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
          title: const Text('Klarna'),
          content: const Text('You have selected Klarna as your payment method. \n\n'
              'With Klarna, you will receive an invoice to your email address with the payment details.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // After the dialog is closed, update the selected payment method and close the page
    _selectPaymentMethod('Facturing (Klarna)');
    Navigator.pop(context, 'Facturing (Klarna)');
  }

  void _confirmCreditCard(String number, String maskedCard) async {
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
          title: const Text('Credit Card'),
          content: const Text('You have selected the Credit Card as your payment method. \n\n'
              'With Credit Card, you will be able to pay with your credit card.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // After the dialog is closed, update the selected payment method and close the page
    _selectPaymentMethod('Credit Card', maskedCard);
    Navigator.pop(context, 'Credit Card');
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
    return Scaffold(
      appBar: TopBar(),
      bottomNavigationBar: const BottomNavBar(
        isEnabled: true,
        currentRoute: '/payment_methods',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a Payment Method:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Credit Card Payment Option
                  PaymentOption(
                    title: 'Credit Card',
                    pngPath: 'assets/png/mastercard.png',
                    onSelect: () => _viewPaymentMethod('Credit Card'),
                    isSelected: selectedPaymentMethod == 'Credit Card',
                    isViewing: currentViewedMethod == 'Credit Card',
                    child: currentViewedMethod == 'Credit Card'
                        ? (selectedPaymentMethod == 'Credit Card'
                            ? paddedContent(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('You have selected the Credit Card with the number:'),
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
                    isSelected: selectedPaymentMethod == 'Google Pay',
                    isViewing: currentViewedMethod == 'Google Pay',
                    child: currentViewedMethod == 'Google Pay'
                        ? (selectedPaymentMethod == 'Google Pay'
                            ? paddedContent(
                                const Text('You have selected Google Pay as your payment method. \n\n'
                                  'With Google Pay, you will be redirected to Google Pay to complete the payment. '
                                  'Please contact Google Pay for more information.'))
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
                    isSelected: selectedPaymentMethod == 'Facturing (Klarna)',
                    isViewing: currentViewedMethod == 'Facturing (Klarna)',
                    child: currentViewedMethod == 'Facturing (Klarna)'
                        ? (selectedPaymentMethod == 'Facturing (Klarna)'
                            ? paddedContent(
                                const Text(
                                  'You have selected Klarna as your payment method. \n\n'
                                  'With Klarna, you will receive an invoice to your email address with the payment details. '
                                  'Please contact Klarna for more information.',
                                  textAlign: TextAlign.center,
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
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        backgroundColor: Color.fromARGB(255, 192, 18, 6),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _deletePaymentMethod,
                      child: const Text('Delete payment method'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
