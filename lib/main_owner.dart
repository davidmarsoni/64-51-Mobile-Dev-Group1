import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:valais_roll/src/app_routes.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'dart:html' if (dart.library.html) 'dart:html';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    await Future.wait([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      dotenv.load(fileName: ".env")
    ]);

    if (kIsWeb) {
      await _initializeGoogleMapsWeb();
      setUrlStrategy(PathUrlStrategy()); // Use path URLs instead of hash
    }

    runApp(const OwnerApp());
  } catch (e) {
    debugPrint('Initialization error: $e');
    rethrow;
  }
}

Future<void> _initializeGoogleMapsWeb() async {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  if (apiKey == null) throw Exception('Google Maps API key not found');

  // Create a new script element
  final script = document.createElement('script') as ScriptElement;
  script.src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey';
  
  // Add the script to document head
  document.head!.append(script);
  
  // Wait for the script to load
  await script.onLoad.first;
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

  Future<bool> _checkUserAuthentication() async {
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
      routes: AppRoutes.getOwnerRoutes(_checkUserAuthentication),
    );
  }
}