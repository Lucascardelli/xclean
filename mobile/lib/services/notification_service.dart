import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/constants.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Solicitar permissão para notificações
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configurar notificações locais
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Configurar canais de notificação para Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notificações Importantes',
      description: 'Canal para notificações importantes do app',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Configurar handlers para mensagens em diferentes estados
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Mostrar notificação local quando o app está em primeiro plano
    await _showLocalNotification(
      title: message.notification?.title ?? 'Nova notificação',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Lidar com mensagem quando o app está em segundo plano
    print('Mensagem em segundo plano: ${message.messageId}');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Notificações Importantes',
      channelDescription: 'Canal para notificações importantes do app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Lidar com o toque na notificação
    if (response.payload != null) {
      // Navegar para a tela apropriada baseado no payload
      print('Notificação tocada com payload: ${response.payload}');
    }
  }
}

// Handler para mensagens em background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensagem em background: ${message.messageId}');
} 