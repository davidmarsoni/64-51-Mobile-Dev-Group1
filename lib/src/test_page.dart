import 'package:flutter/material.dart';
import 'package:valais_roll/src/widgets/base_page.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Test Page',
      body: Center(
        child: Text(
          'This is the Test Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      isBottomNavBarEnabled: true,
    );
  }
}