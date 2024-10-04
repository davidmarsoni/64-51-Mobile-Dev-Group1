import 'package:flutter/material.dart';
import 'package:valais_roll/src/widgets/base_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Center(
        child: Text(
          'The privacy policy page is under construction',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      isBottomNavBarEnabled: true,
    );
  }
}