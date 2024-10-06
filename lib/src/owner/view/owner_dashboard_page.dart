import 'package:flutter/material.dart';
import 'package:valais_roll/src/owner/widgets/base_page.dart';

class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Center(
        child: Text(
          'Hello World\nUnder Construction',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}