import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodbank/signin.dart';

class AccPage extends StatefulWidget {
  const AccPage({super.key});

  @override
  State<AccPage> createState() => _AccPageState();
}

class _AccPageState extends State<AccPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
    }
  }

  // Update user profile (name and password)
  Future<void> updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      try {
        if (user != null) {
          // Update name
          if (_nameController.text.isNotEmpty) {
            await user.updateDisplayName(_nameController.text);
          }

          // Update password if provided
          if (_passwordController.text.isNotEmpty &&
              _newPasswordController.text.isNotEmpty) {
            await user.updatePassword(_newPasswordController.text);
          }

          await user.reload();
          _showSnackBar('Success', 'Profile updated successfully');
        }
      } catch (e) {
        _showSnackBar('Error', 'Failed to update profile: ${e.toString()}');
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    // Navigate to SignInPage using Navigator
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  // Show Snackbar for user feedback
  void _showSnackBar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),

              // Current Password field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              // New Password field
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: const InputDecoration(labelText: "New Password"),
              ),

              const SizedBox(height: 20),

              // Update Profile Button
              ElevatedButton(
                onPressed: updateProfile,
                child: const Text("Update Profile"),
              ),

              const SizedBox(height: 20),

              // Logout Button
              ElevatedButton(
                onPressed: logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
