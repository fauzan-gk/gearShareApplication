import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Set<String> _handledMessageIds = {};

  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage message) async {}

  Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    String? token = await _messaging.getToken();
    await _saveToken(token);

    _messaging.onTokenRefresh.listen(_saveToken);

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigation(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNavigation);
  }

  Future<void> _saveToken(String? token) async {
    if (token == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'fcmToken': token}, SetOptions(merge: true));
    } catch (_) {}
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final msgId = message.messageId;
    if (msgId == null || _handledMessageIds.contains(msgId)) return;
    _handledMessageIds.add(msgId);

    final navigatorKey = _navigatorKey;
    if (navigatorKey?.currentContext == null) return;
    final context = navigatorKey!.currentContext!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.notification?.title ?? 'New update'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _handleNavigation(message),
        ),
      ),
    );
  }

  void _handleNavigation(RemoteMessage message) {
    final screen = message.data['screen'] as String?;
    final route = screen ?? '/home';
    _navigatorKey?.currentState?.pushNamedAndRemoveUntil(route, (r) => false);
  }

  static GlobalKey<NavigatorState>? _navigatorKey;

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }
}
