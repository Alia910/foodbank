import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodbank/signin.dart';
import 'package:foodbank/theme/theme.dart';
import 'package:foodbank/welcome.dart';
import 'package:foodbank/widgets/nav_bar.dart';
import 'package:get/get.dart';
import 'package:foodbank/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Bank App',
      theme: lightMode,
      home: const WelcomePage(), // Show WelcomePage initially
    );
  }
}

class AuthState extends StatelessWidget {
  const AuthState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading indicator
          } else if (snapshot.hasData) {
            return const NavBar(); // Navigate to NavBar if authenticated
          } else {
            return const SignInPage(); // Navigate to SignInPage if not authenticated
          }
        },
      ),
    );
  }
}


