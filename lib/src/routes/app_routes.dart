import 'package:flutter/material.dart';
import 'package:lince_time/src/pages/home_page.dart';
import 'package:lince_time/src/pages/login_and_register/login/login_page.dart';
import 'package:lince_time/src/pages/login_and_register/register/register_page.dart';
import 'package:lince_time/src/pages/splash_page.dart';
import 'package:lince_time/src/pages/admin/admin_page.dart'; // Importa tu AdminPage
import 'package:lince_time/src/routes/routes.dart';

Map<String, Widget Function(BuildContext)> appRoutes = {
  Routes.home: (_) => const HomePage(),
  Routes.login: (_) => LoginPage(),
  Routes.register: (_) => const RegisterPage(),
  Routes.splash: (_) => const SplashPage(),
  Routes.admin: (_) => const AdminPage(), // Agrega la ruta de AdminPage
};
