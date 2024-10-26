import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa Provider
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase
import 'package:recreo/src/routes/app_routes.dart';
import 'package:recreo/src/routes/routes.dart';
import 'package:recreo/src/login_and_register_provider/login_provider.dart'; // Importa tu LoginProvider
import 'package:recreo/src/login_and_register_provider/register_provider.dart'; // Importa tu RegisterProvider si es necesario

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegúrate de que el framework de widgets esté inicializado
  await Firebase.initializeApp(); // Inicializa Firebase aquí
  runApp(const MyApp()); // Ejecuta tu aplicación
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => LoginProvider()), // Incluye LoginProvider
        ChangeNotifierProvider(
            create: (_) =>
                RegisterProvider()), // Incluye RegisterProvider si es necesario
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.splash,
        routes: appRoutes,
      ),
    );
  }
}
