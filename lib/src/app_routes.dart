import 'package:flutter/material.dart';
import 'package:valais_roll/src/owner/view/owner_bike_page.dart';
import 'package:valais_roll/src/owner/view/owner_dashboard_page.dart';
import 'package:valais_roll/src/owner/view/owner_login_page.dart';
import 'package:valais_roll/src/owner/view/owner_station_page.dart';
import 'package:valais_roll/src/user/payment/view/payment_method_page.dart';
import 'package:valais_roll/src/user/others/privacy_policy_page.dart';
import 'package:valais_roll/src/user/user/view/account_page.dart';
import 'package:valais_roll/src/user/welcome/welcome_page.dart';
import 'package:valais_roll/src/user/new_ride/view/itinary_view.dart';
import 'package:valais_roll/src/user/others/emergency_support_page.dart';
import 'package:valais_roll/src/user/user/view/create_account_page.dart';
import 'package:valais_roll/src/user/user/view/login_page.dart';


class AppRoutes {
  static Map<String, WidgetBuilder> getUserRoutes(Future<bool> Function() checkUserAuthentication) {
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

   static Map<String, WidgetBuilder> getOwnerRoutes(Future<bool> Function() checkUserAuthentication) {
    return {
      '/': (context) => FutureBuilder<bool>(
        future: checkUserAuthentication(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return const OwnerDashboardPage();
          } else {
            return const OwnerLoginPage();
          }
        },
      ),
      '/owner_login': (context) => const OwnerLoginPage(),
      '/owner_dashboard': (context) => const OwnerDashboardPage(),
      '/owner_bike': (context) =>  OwnerBikePage(),
      '/owner_station': (context) => OwnerStationPage(),
      '/owner_user': (context) => const OwnerDashboardPage(),
      '/owner_account': (context) => const OwnerDashboardPage(),
    };
  }
}