import 'package:flutter/material.dart';
import 'package:valais_roll/src/widgets/base_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePage(
      title: 'ValaisRoll',
      body: Padding(
        padding: EdgeInsets.all(20.0), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text(
              'Welcome to ValaisRoll!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      isBottomNavBarEnabled: false,
    );
  }
}