import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:valais_roll/src/widgets/base_page.dart';
import 'package:valais_roll/src/widgets/button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'ValaisRoll',
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to ValaisRoll!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Button(
                    text: 'Create Account',
                    onPressed: () {
                      Navigator.pushNamed(context, '/create_account');
                    },
                    horizontalPadding: 20,
                    isFilled: true,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Button(
                    text: 'Login',
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    isFilled: false, // This is an outlined button
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
              height: MediaQuery.of(context).size.height * 0.75,
            ),
          ],
        ),
      ),
      isBottomNavBarEnabled: false,
    );
  }
}