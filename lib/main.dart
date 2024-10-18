import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:valais_roll/src/app_routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  Future<bool> _checkUserAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ValaisRoll',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF309874)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: AppRoutes.getUserRoutes(_checkUserAuthentication),
    );
  }
}