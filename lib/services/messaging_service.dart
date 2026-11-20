import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  final _fcm = FirebaseMessaging.instance;
  String? _initializedFor;

  Future<void> init(String uid) async {
    if (_initializedFor == uid) return;
    _initializedFor = uid;
    try {
      final settings = await _fcm.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await _fcm.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'fcmToken': token});
      }
      _fcm.onTokenRefresh.listen((t) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'fcmToken': t});
      });
    } catch (e) {
      debugPrint('FCM init skipped: $e');
    }
  }

  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;
}
