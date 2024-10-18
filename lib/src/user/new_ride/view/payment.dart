import 'dart:async';
import 'package:flutter/material.dart';
import 'package:valais_roll/src/user/new_ride/view/billinfo.dart';

class Payment extends StatefulWidget {
  final String paymentMethod;

  const Payment({super.key, required this.paymentMethod});

  @override
  State<Payment> createState() => _PaymentState();

  // Add the static show method here
  static void show(BuildContext context, {required String paymentMethod}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Payment(paymentMethod: paymentMethod),
      ),
    );
  }
}

class _PaymentState extends State<Payment> {
  late Color backgroundColor;
  late String message;

  @override
  void initState() {
    super.initState();

    // Set color and message based on payment method
    switch (widget.paymentMethod) {
      case 'klarna':
        backgroundColor = Colors.pink;
        message = "Processing Klarna...";
        break;
      case 'google_pay':
        backgroundColor = Colors.blue;
        message = "Processing Google Pay...";
        break;
      case 'credit_card':
        backgroundColor = Colors.orange; 
        message = "Processing Credit Card...";
        break;
      default:
        backgroundColor = Colors.grey; 
        message = "Processing payment...";
    }

    // Start a timer based on the color and close the page after the delay
    int delayInSeconds = 4;
    Timer(Duration(seconds: delayInSeconds), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
