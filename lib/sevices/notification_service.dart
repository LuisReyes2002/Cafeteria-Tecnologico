import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lince_time/src/routes/app_routes.dart';
import 'package:lince_time/src/routes/routes.dart';
import 'package:lince_time/src/login_and_register_provider/login_provider.dart';
import 'package:lince_time/src/login_and_register_provider/register_provider.dart';

// Configuración para notificaciones locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Registrar el listener para mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Configuración inicial de notificaciones
  await setupNotificationChannel();

  // Obtén y muestra el token FCM
  await getToken();

  // Configurar listeners de mensajes
  setupMessageHandlers();

  runApp(const MyApp());
}

// Configurar el canal de notificaciones
Future<void> setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // Id del canal
    'High Importance Notifications', // Nombre del canal
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Inicialización de notificaciones locales
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_notification');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      print('Notification clicked with payload: ${details.payload}');
      // Aquí puedes redirigir a una pantalla específica si es necesario
    },
  );
}

// Obtener el token de FCM
Future<void> getToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Obtén el token FCM del dispositivo
  String? fcmToken = await messaging.getToken();

  if (fcmToken != null) {
    print("FCM Token: $fcmToken");
    // Puedes guardar el token en tu LoginProvider o base de datos
  } else {
    print("Error al obtener el FCM Token.");
  }
}

// Configurar listeners para mensajes en primer plano y segundo plano
void setupMessageHandlers() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Mensaje recibido en primer plano: ${message.notification?.title}");
    showLocalNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Mensaje abierto desde notificación: ${message.notification?.title}");
    // Aquí puedes manejar la lógica para redirigir al usuario
  });
}

// Handler para mensajes en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Mensaje recibido en segundo plano: ${message.notification?.title}");
}

// Mostrar una notificación local
void showLocalNotification(RemoteMessage message) {
  final notification = message.notification;
  final android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel', // Id del canal
          'High Importance Notifications', // Nombre del canal
          channelDescription:
              'This channel is used for important notifications.',
          icon: '@drawable/ic_notification',
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
      ],
      child: Consumer<LoginProvider>(
        builder: (context, loginProvider, child) {
          if (loginProvider.authStatus == AuthStatus.checking) {
            return const Center(child: CircularProgressIndicator());
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: _getInitialRoute(loginProvider),
            routes: appRoutes,
          );
        },
      ),
    );
  }

  String _getInitialRoute(LoginProvider loginProvider) {
    if (loginProvider.authStatus == AuthStatus.authenticated) {
      if (loginProvider.role == 'admin') {
        return Routes.admin;
      } else if (loginProvider.role == 'user') {
        return Routes.home;
      }
    }
    return Routes.splash;
  }
}
