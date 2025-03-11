import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodbank/admin.dart'; // Admin dashboard page
import 'package:foodbank/signup.dart';
import 'package:foodbank/theme/theme.dart';
import 'package:foodbank/widgets/custom_scaffold.dart';
import 'package:foodbank/widgets/nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formSignIn = GlobalKey<FormState>();
  bool rememberPass = true;
  bool _isPasswordVisible = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email.text = prefs.getString('REMEMBERED_EMAIL') ?? '';
      password.text = prefs.getString('REMEMBERED_PASSWORD') ?? '';
      rememberPass = prefs.getBool('REMEMBER_ME') ?? false;
    });
  }

  Future<void> signIn() async {
    if (_formSignIn.currentState!.validate()) {
      final String emailText = email.text.trim();
      final String passwordText = password.text.trim();

      try {
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailText,
          password: passwordText,
        );

        final User? user = userCredential.user;
        if (user != null) {
          final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

          if (userDoc.exists) {
            final bool isAdmin = userDoc.data()?['isAdmin'] ?? false;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (rememberPass) {
              await prefs.setString('REMEMBERED_EMAIL', emailText);
              await prefs.setString('REMEMBERED_PASSWORD', passwordText);
              await prefs.setBool('REMEMBER_ME', true);
            } else {
              await prefs.remove('REMEMBERED_EMAIL');
              await prefs.remove('REMEMBERED_PASSWORD');
              await prefs.setBool('REMEMBER_ME', false);
            }

            if (mounted) {
              if (isAdmin) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPage()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const NavBar()),
                );
              }
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.message}')),
          );
        }
      }
    }
  }

  Future<void> sendPasswordResetEmail() async {
    if (email.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset email sent')),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignIn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const Text(
                        'Sign in to continue\n',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextFormField(
                        controller: email,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter email' : null,
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: password,
                        obscureText: !_isPasswordVisible,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter password' : null,
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPass,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPass = value!;
                                  });
                                },
                              ),
                              const Text('Remember me'),
                            ],
                          ),
                          GestureDetector(
                            onTap: sendPasswordResetEmail,
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: lightColorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: signIn,
                          child: const Text('Sign in'),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (e) => const SignUpPage()),
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                color: lightColorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
