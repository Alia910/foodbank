import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _initializeFCM();
    _loadNotificationsFromFirestore();
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission.');
      } else {
        debugPrint('User declined notification permission.');
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  /// Initialize Firebase Cloud Messaging
  void _initializeFCM() {
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        final newNotification = {
          'title': message.notification!.title ?? 'No Title',
          'message': message.notification!.body ?? 'No Body',
          'timestamp': DateTime.now(),
        };

        setState(() {
          _notifications.insert(0, newNotification);
        });

        FirebaseFirestore.instance.collection('notifications').add({
          'title': newNotification['title'],
          'body': newNotification['body'],
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
  }

  /// Load notifications from Firestore
  Future<void> _loadNotificationsFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _notifications.addAll(snapshot.docs.map((doc) => {
          'id': doc.id,
          'title': doc['title'],
          'body': doc['body'],
          'timestamp': doc['timestamp']?.toDate() ?? DateTime.now(),
        }));
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications available.'))
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(notification['title']),
              subtitle: Text(notification['body']),
              trailing: Text(
                notification['timestamp'].toString(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
