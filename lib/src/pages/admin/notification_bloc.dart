import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart' as event; // Alias para evitar el conflicto
import 'notification_state.dart' as state; // Alias para evitar el conflicto
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationBloc
    extends Bloc<event.NotificationEvent, state.NotificationBaseState> {
  NotificationBloc() : super(state.NotificationInitial());

  @override
  Stream<state.NotificationBaseState> mapEventToState(
      event.NotificationEvent notificationEvent) async* {
    if (notificationEvent is event.NewOrderEvent) {
      yield state.NotificationLoading();
      try {
        // Lógica para enviar la notificación a los administradores
        await sendNotificationToAdmins(notificationEvent.orderId);
        yield state.NotificationSuccess('Nuevo pedido recibido!');
      } catch (e) {
        yield state.NotificationFailure(e.toString());
      }
    }
  }

  Future<void> sendNotificationToAdmins(String orderId) async {
    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get()
        .then((querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        String? fcmToken = doc['fcmToken'];

        if (fcmToken != null && fcmToken.isNotEmpty) {
          await sendPushNotification(fcmToken, orderId);
        }
      }
    });
  }

  Future<void> sendPushNotification(String fcmToken, String orderId) async {
    final String serverKey =
        'AIzaSyC0ce5F2yisWCFa1UKZUKhpDdPFfdBKQHY'; // Reemplaza con tu servidor FCM Key

    final Map<String, dynamic> message = {
      'to': fcmToken,
      'notification': {
        'title': 'Nuevo Pedido',
        'body': '¡Tienes un nuevo pedido con ID: $orderId!',
      },
      'priority': 'high',
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: json.encode(message),
    );

    if (response.statusCode == 200) {
      print('Notificación enviada con éxito');
    } else {
      print('Error al enviar la notificación: ${response.body}');
    }
  }
}
