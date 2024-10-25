import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:valais_roll/src/app_routes.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  registerPlugins(webPluginRegistrar);
  runApp(const OwnerApp());
}

void registerPlugins(Registrar registrar) {
  GoogleMapsPlugin.registerWith(registrar);
}

class OwnerApp extends StatelessWidget {
  const OwnerApp({super.key});

  Future<bool> _checkUserAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ValaisRoll Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF309874)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: AppRoutes.getOwnerRoutes(_checkUserAuthentication),
    );
  }
}