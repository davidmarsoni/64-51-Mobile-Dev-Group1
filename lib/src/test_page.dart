import 'package:flutter/material.dart';
import 'package:valais_roll/src/widgets/top_bar.dart';
import 'package:valais_roll/src/widgets/nav_bar.dart'; 

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: 'Test Page',
      ),
      body: Center(
        child: Text('This is the Test Page'),
      ),
      bottomNavigationBar: BottomNavBar(isEnabled: true), 
    );
  }
}