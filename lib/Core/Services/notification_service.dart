import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'auth_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Background: ${message.notification?.title}');
}

class NotificationService {
  NotificationService._();

  static final _db = FirebaseFirestore.instance;
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static StreamSubscription? _notifSubscription;

  static const _channelId = 'dar_miqdad_channel';
  static const _channelName = 'دار المقداد';

  // ═══════════════════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════════════════
  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _requestPermission();
    await _setupLocalNotifications();

    // FCM للـ background/terminated
    FirebaseMessaging.onMessage.listen(_onFCMForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotifTap);
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleData(initial.data);
  }

  // بعد login مباشرة
  static Future<void> onUserLoggedIn() async {
    await _subscribeToTopic();
    _listenToFirestoreNotifications();
  }

  // عند logout
  static Future<void> onUserLoggedOut() async {
    await _unsubscribeFromTopic();
    _notifSubscription?.cancel();
  }

  // ─── Permission ───────────────────────────────────────────
  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  // ─── Subscribe to Topic ───────────────────────────────────
  static Future<void> _subscribeToTopic() async {
    await _messaging.subscribeToTopic('dar_miqdad_store');
    debugPrint('✅ Subscribed to topic');
  }

  static Future<void> _unsubscribeFromTopic() async {
    await _messaging.unsubscribeFromTopic('dar_miqdad_store');
  }

  // ─── Local Notifications Setup ────────────────────────────
  static Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _handleData({'type': details.payload});
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
            playSound: true,
          ),
        );
  }

  // ═══════════════════════════════════════════════════════════
  // FIRESTORE LISTENER — التطبيق شغال (Foreground)
  // ═══════════════════════════════════════════════════════════
  static void _listenToFirestoreNotifications() {
    _notifSubscription?.cancel();

    final now = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(seconds: 2)),
    );

    _notifSubscription = _db
        .collection('store_notifications')
        .where('createdAt', isGreaterThan: now)
        .snapshots()
        .listen((snap) {
          for (final change in snap.docChanges) {
            if (change.type != DocumentChangeType.added) continue;

            final data = change.doc.data()!;

            // ما تعرض إشعار لنفس الشخص اللي أضاف

            _showLocalNotification(
              title: data['title'] ?? '',
              body: data['body'] ?? '',
              type: data['type'] ?? '',
            );
          }
        });
  }

  // ─── Show Local Notification ──────────────────────────────
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFFC9A84C),
          icon: '@drawable/ic_notification',
        ),
      ),
      payload: type,
    );
  }

  // ─── FCM Foreground ───────────────────────────────────────
  static Future<void> _onFCMForeground(RemoteMessage msg) async {
    final n = msg.notification;
    if (n == null) return;
    await _showLocalNotification(
      title: n.title ?? '',
      body: n.body ?? '',
      type: msg.data['type'] ?? '',
    );
  }

  static void _onNotifTap(RemoteMessage msg) => _handleData(msg.data);

  static void _handleData(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'payment':
        Get.toNamed('/payments');
        break;
      case 'transfer':
      case 'transfer_updated':
        Get.toNamed('/transfers');
        break;
      case 'outgoing':
        Get.toNamed('/outgoing-transfers');
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SEND — يكتب في Firestore بس
  // ═══════════════════════════════════════════════════════════
  static Future<void> _send({
    required String title,
    required String body,
    required String type,
  }) async {
    final currentUid = AuthService.currentUser?.uid ?? '';

    await _db.collection('store_notifications').add({
      'title': title,
      'body': body,
      'type': type,
      'createdBy': currentUid,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 1)),
      ),
    });
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLIC METHODS
  // ═══════════════════════════════════════════════════════════
  static Future<void> notifyPaymentAdded({
    required String customerName,
    required double amount,
    required String accountName,
  }) async {
    await _send(
      title: '💳 دفعة جديدة',
      body: '$customerName — ₪${amount.toStringAsFixed(2)} على $accountName',
      type: 'payment',
    );
  }

  static Future<void> notifyTransferAdded({
    required String senderName,
    required double amount,
    required String accountName,
    required String status,
  }) async {
    final statusLabel = status == 'received' ? 'واصلة ✅' : 'معلقة ⏳';
    await _send(
      title: '💸 حوالة واردة جديدة',
      body:
          '$senderName — ₪${amount.toStringAsFixed(2)} على $accountName ($statusLabel)',
      type: 'transfer',
    );
  }

  static Future<void> notifyTransferUpdated({
    required String senderName,
    required double amount,
  }) async {
    await _send(
      title: '✅ تم تأكيد حوالة',
      body: 'حوالة $senderName — ₪${amount.toStringAsFixed(2)} تم تأكيد وصولها',
      type: 'transfer_updated',
    );
  }

  static Future<void> notifyOutgoingAdded({
    required String recipientName,
    required double amount,
    required String category,
  }) async {
    await _send(
      title: '📤 مصروف جديد',
      body:
          '$recipientName — ₪${amount.toStringAsFixed(2)} (${_catLabel(category)})',
      type: 'outgoing',
    );
  }

  static String _catLabel(String cat) {
    switch (cat) {
      case 'supplies':
        return 'مستلزمات';
      case 'bills':
        return 'فواتير';
      case 'salaries':
        return 'رواتب';
      default:
        return 'أخرى';
    }
  }
}
