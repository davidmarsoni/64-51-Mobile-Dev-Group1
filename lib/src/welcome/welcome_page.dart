import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:valais_roll/src/auth/create_account/create_account_page.dart';
import 'package:valais_roll/src/auth/login/login_page.dart';
import 'package:valais_roll/src/widgets/base_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'ValaisRoll',
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Add 20px padding outside the main frame
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align content to the top
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start horizontally
          children: [
            const Text(
              'Welcome to ValaisRoll!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0), // Increase button height
                      textStyle: const TextStyle(fontSize: 18), // Increase font size
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateAccountPage()),
                      );
                    },
                    child: const Text('Get started now'),
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add left and right padding
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0), // Increase button height and width
                      textStyle: const TextStyle(fontSize: 18), // Increase font size
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'By creating an account in our application you acknowledge that you have read and understood, and agree to our Terms & Privacy.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            SvgPicture.asset(
              'assets/svg/welcome.svg', 
              height: MediaQuery.of(context).size.height * 0.75, // 75% of the screen height
            ),
          ],
        ),
      ),
      isBottomNavBarEnabled: false,
    );
  }
}