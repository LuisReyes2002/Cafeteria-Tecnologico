import 'package:flutter/material.dart';
import 'package:lince_time/src/pages/admin/notification_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Agregar import para Bloc
import 'package:lince_time/src/routes/app_routes.dart';
import 'package:lince_time/src/routes/routes.dart';
import 'package:lince_time/src/login_and_register_provider/login_provider.dart';
import 'package:lince_time/src/login_and_register_provider/register_provider.dart';
import 'firebase_options.dart'; // Importar el archivo generado por FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con las opciones específicas para la plataforma actual
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        BlocProvider(
            create: (_) =>
                NotificationBloc()), // Proveedor para el NotificationBloc
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
