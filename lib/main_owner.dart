import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:valais_roll/src/app_routes.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:html' as html;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());

    // API key
    // This is a public key, so it's okay to include it in the source code for this project because it's restricted to the project's domain only
    final apiKey = "AIzaSyAPTmWuDEWsoAh-U72eqplX9j1vnwazKpE";

    // Dynamically insert the Google Maps script
    final script = html.ScriptElement()
      ..type = 'text/javascript'
      ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
      ..async = true;
    html.document.head!.append(script);

    // Wait for the script to load
    await script.onLoad.first;
  }

  runApp(const OwnerApp());
}

class OwnerApp extends StatefulWidget {
  const OwnerApp({super.key});

  @override
  State<OwnerApp> createState() => _OwnerAppState();
}

class _OwnerAppState extends State<OwnerApp> {
  late final FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
  }

  Future<bool> checkUserAuthentication() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Verify token is still valid
      await user.getIdToken();
      return true;
    } catch (e) {
      debugPrint('Authentication check failed: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ValaisRoll Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF309874),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: AppRoutes.getOwnerRoutes(checkUserAuthentication),
    );
  }
}