import 'package:flutter/material.dart';
import 'package:valais_roll/src/test_page.dart';
import 'package:valais_roll/src/widgets/nav_bar.dart';
import 'package:valais_roll/src/widgets/top_bar.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: "Home page"), // Use TopBar component
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello World',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TestPage()),
                );
              },
              child: const Text('Go to Test Page'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(isEnabled: true), // Use BottomNavBar component
    );
  }
}