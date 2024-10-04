import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:valais_roll/src/login/login_page.dart';
import 'package:valais_roll/src/test_page.dart';
import 'package:valais_roll/src/widgets/nav_bar.dart';
import 'package:valais_roll/src/widgets/top_bar.dart'; 
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, 
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isNavBarEnabled = true;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _addEntryToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('entries').add({
        'timestamp': FieldValue.serverTimestamp(),
        'counter': _counter,
        'uid': user.uid,
      });
    } else {
      print('User is not authenticated');
    }
  }

  void _navigateToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToTestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TestPage()),
    );
  }

  void _toggleNavBar() {
    setState(() {
      _isNavBarEnabled = !_isNavBarEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: widget.title), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addEntryToFirestore,
              child: const Text('Add Entry to Firestore'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToLoginPage,
              child: const Text('Go to Login Page'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToTestPage,
              child: const Text('Go to Test Page'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(isEnabled: _isNavBarEnabled), 
    );
  }
}