import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationsPage extends StatefulWidget {
  final List<String> notifications;

  const DonationsPage({super.key, required this.notifications});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  final TextEditingController _donationAmountController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  // Create a modifiable copy of notifications
  late List<String> _modifiableNotifications;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;

    // Initialize the modifiable copy of notifications
    _modifiableNotifications = List<String>.from(widget.notifications);

    if (_currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Please log in to make a donation.')),
        );
        Navigator.of(context).pop(); // Redirect to the previous screen
      });
    }
  }

  /// Handle donation submission
  Future<void> _submitDonation() async {
    final amount = _donationAmountController.text.trim();

    // Validate input
    if (amount.isEmpty || double.tryParse(amount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid donation amount.')),
      );
      return;
    }

    try {
      final donationData = {
        'userId': _currentUser?.uid,
        'amount': double.parse(amount),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save donation to Firestore
      debugPrint('Saving donation to Firestore...');
      await FirebaseFirestore.instance.collection('donations').add(donationData);
      debugPrint('Donation saved successfully.');

      // Add a notification for the donation
      setState(() {
        _modifiableNotifications.add('Thank you for donating RM${amount}.');
      });

      // Save the donation notification to Firestore
      debugPrint('Saving notification to Firestore...');
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Donation Received',
        'body': 'Thank you for donating RM${amount}.',
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Notification saved successfully.');

      // Clear the input field after donation
      _donationAmountController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you for your donation of RM${amount}!')),
      );
    } catch (e) {
      debugPrint('Error submitting donation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting donation: $e')),
      );
    }
  }

  /// Build the donation form UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Make a Donation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xff083c81),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter the amount you would like to donate:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _donationAmountController,
              decoration: const InputDecoration(
                hintText: 'Donation Amount (e.g., 10)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff083c81),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Submit Donation'),
            ),
          ],
        ),
      ),
    );
  }
}
