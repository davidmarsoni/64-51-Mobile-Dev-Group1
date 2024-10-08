import 'package:flutter/material.dart';
import 'package:valais_roll/src/others/privacy_policy_page.dart';
import 'package:valais_roll/src/payment/view/payment_method_page.dart';
import 'package:valais_roll/src/user/view/account_page.dart';
import 'package:valais_roll/src/welcome/welcome_page.dart';
import 'package:valais_roll/src/new_ride/view/itinary_view.dart';
import 'package:valais_roll/src/others/emergency_support_page.dart';
import 'package:valais_roll/src/user/view/create_account_page.dart';
import 'package:valais_roll/src/user/view/login_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes(Future<bool> Function() checkUserAuthentication) {
    return {
      '/': (context) => FutureBuilder<bool>(
        future: checkUserAuthentication(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return const ItineraryPage();
          } else {
            return const WelcomePage();
          }
        },
      ),
      '/welcome': (context) => const WelcomePage(),
      '/create_account': (context) => const CreateAccountPage(),
      '/login': (context) => const LoginPage(),
      '/account': (context) => const AccountPage(),
      '/home': (context) => const ItineraryPage(),
      '/itinerary': (context) => const ItineraryPage(),
      '/emergency_support': (context) => const EmergencySupportPage(),
      '/privacy_policy': (context) => const PrivacyPolicyPage(),
      '/paymentApp': (context) => const PaymentMethodPage(),
    };
  }
}