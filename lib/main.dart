import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:valais_roll/src/welcome/welcome_page.dart';
import 'package:valais_roll/src/new_ride/view/itinary_view.dart';
import 'package:valais_roll/src/others/emergency_support_page.dart';
import 'package:valais_roll/src/auth/create_account/create_account_page.dart';
import 'package:valais_roll/src/auth/login/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkUserAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ValaisRoll',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
          future: _checkUserAuthentication(),
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
        '/home': (context) => const ItineraryPage(),
        '/welcome': (context) => const WelcomePage(),
        '/itinerary': (context) => const ItineraryPage(),
        '/emergencySupport': (context) => const EmergencySupportPage(),
        '/createAccount': (context) => const CreateAccountPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}