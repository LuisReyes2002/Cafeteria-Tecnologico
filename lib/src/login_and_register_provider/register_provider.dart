import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RegisterProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Función para guardar el token de dispositivo en Firestore
  Future<void> _saveDeviceToken(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'deviceToken': token,
        });
      }
    } catch (e) {
      print("Error al guardar el token de dispositivo: $e");
    }
  }

  Future<bool> registerUser({
    required String username,
    required String matricula,
    required String password,
    required String tel,
    required String email,
    required Function(String) onError,
    required Function(String) onWarning,
  }) async {
    try {
      // Validaciones
      if (!RegExp(r'^[0-9]{8}$').hasMatch(matricula)) {
        onError('La matrícula debe contener exactamente 8 dígitos.');
        return false;
      }
      if (!RegExp(r'^\d{10}$').hasMatch(tel)) {
        onError('El número de teléfono debe contener 10 dígitos.');
        return false;
      }
      if (!email.endsWith('@gmail.com')) {
        onError('El correo electrónico debe terminar en @gmail.com.');
        return false;
      }

      // Registro en Firebase
      String userId = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guarda los detalles del usuario en Firestore
      await _firestore.collection('users').doc(userId).set({
        'username': username,
        'matricula': matricula,
        'tel': tel,
        'email': email,
        'role': 'user',
        'fcmToken': '',
        'deviceToken': '', // Campo para el token del dispositivo
      });

      // Enviar correo de verificación
      await _authService.sendVerificationEmail();

      // Guardar el token del dispositivo después del registro
      await _saveDeviceToken(userId);

      return true;
    } catch (e) {
      onError('Error al registrar: ${e.toString()}');
      return false;
    }
  }
}
