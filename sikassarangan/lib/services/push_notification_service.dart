import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../screens/notifikasi_screen.dart';

/// Menangani seluruh alur push notification:
/// - minta izin + ambil FCM token
/// - tampilkan notifikasi saat foreground (flutter_local_notifications)
/// - navigasi ke NotifikasiScreen saat notifikasi di-tap (background/terminated)
/// - memancarkan [onMessage] agar app bisa refresh daftar & unread count.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialized = false;

  /// Setiap pesan masuk (foreground / tap) dipancarkan di sini.
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'sikassarangan_default',
    'Notifikasi siKasSarangan',
    description: 'Notifikasi transaksi & pengumuman kas',
    importance: Importance.high,
    playSound: true,
  );

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _navigatorKey = navigatorKey;

    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _local.initialize(
      settings:  initSettings,
      onDidReceiveNotificationResponse: (response) =>
          _handleTapPayload(response.payload),
    );

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Foreground: tampilkan sendiri lewat local notification + pancarkan event.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    // Notifikasi di-tap saat app di background.
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    // Notifikasi yang membuka app dari kondisi terminated.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messageController.add(initialMessage);
        _openNotifikasiScreen();
      });
    }
  }

  Future<void> requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  void _onForegroundMessage(RemoteMessage message) {
    _messageController.add(message);

    final notification = message.notification;
    if (notification == null) {
      return;
    }

    _local.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          icon: '@drawable/ic_notification',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: 'notifikasi',
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    _messageController.add(message);
    _openNotifikasiScreen();
  }

  void _handleTapPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return;
    }
    _openNotifikasiScreen();
  }

  void _openNotifikasiScreen() {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      return;
    }
    navigator.push(MaterialPageRoute(builder: (_) => const NotifikasiScreen()));
  }
}
