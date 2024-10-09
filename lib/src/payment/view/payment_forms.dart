import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valais_roll/src/payment/view/payment_method_page.dart';
import 'package:valais_roll/src/widgets/button.dart';

// Credit Card Form Widget
class CreditCardForm extends StatefulWidget {
  final Function(String number, String maskedNumber) onConfirm;
  final bool isLoading;

  const CreditCardForm({
    required this.onConfirm,
    required this.isLoading,
    Key? key,
  }) : super(key: key);

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // Validate Credit Card Number (without spaces)
  bool _isValidCardNumber(String number) {
    final cleanedNumber = number.replaceAll(RegExp(r'\s+\b|\b\s'), ''); // Remove spaces
    return cleanedNumber.length == 16 && int.tryParse(cleanedNumber) != null;
  }

  // Validate Expiry Date (MM/YY format)
  bool _isValidExpiryDate(String expiryDate) {
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!regex.hasMatch(expiryDate)) return false;

    final parts = expiryDate.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');

    final now = DateTime.now();
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    return lastDayOfMonth.isAfter(now);
  }

  // Validate CVV
  bool _isValidCvv(String cvv) {
    //check that the cvv is 3 digits long and only contains numbers
    return cvv.length == 3 && int.tryParse(cvv) != null;
  }

  // Mask the card number (removing spaces)
  String _maskCardNumber(String number) {
    final cleanedNumber = number.replaceAll(RegExp(r'\s+\b|\b\s'), ''); 
    return '${cleanedNumber.substring(0, 4)}XXXXXXXXXX${cleanedNumber.substring(cleanedNumber.length - 2)}';
  }

  // Formatter to add spaces after every 4 digits
  final _creditCardFormatter = _CreditCardNumberFormatter();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _numberController,
            decoration: const InputDecoration(labelText: 'Card Number'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow digits only
              _creditCardFormatter, // Add formatter for spacing
            ],
            validator: (value) {
              if (value == null || !_isValidCardNumber(value)) {
                return 'Enter a valid 16-digit card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _expiryController,
            decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
            keyboardType: TextInputType.datetime,
            inputFormatters: [
              _ExpiryDateFormatter(), // Custom formatter for expiry date
            ],
            validator: (value) {
              if (value == null || !_isValidExpiryDate(value)) {
                return 'Enter a valid expiry date';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cvvController,
            decoration: const InputDecoration(labelText: 'CVV'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || !_isValidCvv(value)) {
                return 'Enter a valid 3-digit CVV';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          widget.isLoading
              ? const CircularProgressIndicator()
              : Button(
                  text: 'Confirm Credit Card',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String number = _numberController.text;
                      String maskedNumber = _maskCardNumber(number);
                      widget.onConfirm(number, maskedNumber);
                    }
                  },
                ),
        ],
      ),
    );
  }
}

// Custom Formatter to insert space after every 4 digits
class _CreditCardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'\s+\b|\b\s'), ''); // Remove any existing spaces

    if (newText.length > 16) {
      newText = newText.substring(0, 16); // Limit to 16 digits
    }

    // Insert spaces after every 4 digits
    String spacedText = '';
    for (int i = 0; i < newText.length; i++) {
      if (i % 4 == 0 && i != 0) {
        spacedText += ' ';
      }
      spacedText += newText[i];
    }

    return newValue.copyWith(
      text: spacedText,
      selection: TextSelection.collapsed(offset: spacedText.length),
    );
  }
}

// Custom Formatter for Expiry Date (MM/YY)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll('/', ''); // Remove any existing '/' characters

    if (newText.length > 4) {
      newText = newText.substring(0, 4); // Limit to 4 digits (MMYY)
    }

    // Insert '/' after the first 2 digits
    if (newText.length >= 2) {
      newText = newText.substring(0, 2) + '/' + newText.substring(2);
    }

    // Handle backspace deletion of '/' character
    if (oldValue.text.length == 4 && newValue.text.length == 3) {
      newText = newText.substring(0, 2);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// Google Pay Form Widget
class GooglePayForm extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool isLoading;

  const GooglePayForm({required this.onConfirm, required this.isLoading, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (isLoading)
            Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Google Blue
                ),
                const SizedBox(height: 16),
                const Text('Processing Google Pay...'),
              ],
            )
          else
            Column(
              children: [
                const Text('Proceed with Google Pay to complete your payment. '
                    'You will be redirected to Google Pay to complete the payment. '
                    'By proceeding with Google Pay, you agree to the terms and conditions of Google Pay. '
                    'For more information, visit Google Pay\'s website.'),
                const SizedBox(height: 16),
                Button(text: 'Use Google Pay', onPressed: onConfirm),
              ],
            ),
        ],
      ),
    );
  }
}

// Facturing Form (Klarna) Widget
class FacturingForm extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool isLoading;

  const FacturingForm({required this.onConfirm, required this.isLoading, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (isLoading)
            Column(
              children: [
                CircularProgressIndicator(
                  color: Colors.pink, // Klarna Color
                ),
                const SizedBox(height: 16),
                const Text('Klarna is checking...'),
              ],
            )
          else
            Column(
              children: [
                const Text('Proceed with Klarna, the facturing service, to complete your payment. '
                    'You will receive an invoice to your email at the end of the month by Klarna with the payment details. '
                    'You can pay the invoice within 14 days. '
                    'By proceeding with Klarna, you agree to the terms and conditions of Klarna. '
                    'For more information, visit Klarna\'s website.'),
                const SizedBox(height: 16),
                Button(text: 'Use Klarna', onPressed: onConfirm),
              ],
            ),
        ],
      ),
    );
  }
}