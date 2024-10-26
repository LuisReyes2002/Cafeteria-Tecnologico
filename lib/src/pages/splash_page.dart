import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Necesario para obtener el rol del usuario

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Verificar si el usuario ya está autenticado después de que se complete el ciclo de construcción
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserSession();
    });
  }

  // Método para verificar si hay un usuario autenticado y su rol
  Future<void> _checkUserSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Si ya hay un usuario autenticado, obtener su rol de Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final String role = userDoc.get('role'); // Obtener el rol del usuario
        if (role == 'admin') {
          // Si el usuario es administrador, redirigir a la página de administrador
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (role == 'user') {
          // Si el usuario es normal, redirigir a la página de inicio
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Si no se encuentra el rol, cerrar sesión y redirigir al login
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // Si no hay usuario autenticado, redirigir al login
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white, // Fondo blanco
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash.png',
              width: 400,
              height: 400,
              fit: BoxFit.contain, // Ajusta la imagen manteniendo la proporción
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
