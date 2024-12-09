import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print("Servicio de notificaciones inicializado.");
  }

  // Enviar notificación a través de Firebase Messaging
  static Future<void> sendNotification({
    required String title,
    required String body,
    required String token,
  }) async {
    try {
      // Usamos `FirebaseMessaging.instance` para enviar el mensaje
      await FirebaseMessaging.instance.sendMessage(
        to: token,
        data: {
          'title': title,
          'body': body,
        },
      );
      print("Notificación enviada: $title");
    } catch (e) {
      print("Error al enviar la notificación: $e");
    }
  }

  // Manejo de mensajes en segundo plano
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Mensaje recibido en segundo plano: ${message.notification?.title}");
  }
}
