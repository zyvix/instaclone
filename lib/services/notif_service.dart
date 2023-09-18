import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifService{

  static Future<void> init() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "high_importance_channel",
      "High Importance Notifications",
      description: "This channel is used for important notifications.",
      importance: Importance.max,
    );



    var initAndroidSetting = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initIosSetting = const DarwinInitializationSettings();
    var initSetting = InitializationSettings(
      android: initAndroidSetting,
      iOS: initIosSetting,
    );

    await FlutterLocalNotificationsPlugin()
        .initialize(initSetting, onDidReceiveNotificationResponse: _handleMessage);

    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  }

  static void _handleMessage(NotificationResponse? message){}

}