import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';

class PushService {
  late final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  Future<void> initialize({bool background = false}) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('launch_background');
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);
    await _localNotificationsPlugin.initialize(initializationSettings);

    if (!background) {
      FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // todo handle implication if permission not granted
      if (Platform.isAndroid) {
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } else if (Platform.isAndroid) {
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
//            critical: true
        );
      }
      await FirebaseMessaging.instance.subscribeToTopic("global");
    }
  }


  Future<void> _showMessage(String title, String body, [bool important = false]) async {
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'appus', 'Appus',
        importance: important ? Importance.max : Importance.defaultImportance,
        priority: important ? Priority.high : Priority.defaultPriority);
    DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
        interruptionLevel: important ? InterruptionLevel.timeSensitive : InterruptionLevel.active
    );
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);
    await _localNotificationsPlugin.show(title.hashCode, title, body, notificationDetails);
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;

    switch (data["type"]) {
      case "regional_alert":
        _handleMessageRegionalAlert(data["content"] as String);
        break;
    }
  }

  void _handleMessageRegionalAlert(String contentJson) {
    final Map<String, dynamic> content = jsonDecode(contentJson);
    final title = content["title"] as String;
    final body = content["body"] as String;
    final important = content["important"] == true;

    _showMessage(title, body, important);
  }
}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  final pushService = PushService();
  await pushService.initialize(background: true);
  pushService._handleMessage(message);
}