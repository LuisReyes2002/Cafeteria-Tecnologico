import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { authenticated, unauthenticated, checking }

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  AuthStatus authStatus = AuthStatus.unauthenticated;
  bool isLoading = false;
  String? _matricula;
  String? get matricula => _matricula;
  String? _role;
  String? get role => _role;

  Future<void> saveLastScreen(String screenName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_screen', screenName);
  }

  Future<String?> getLastScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_screen') ?? '';
  }

  // Función para guardar el token FCM en el campo fcmToken de Firestore
  Future<void> _saveDeviceToken(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        // Guarda el token en el campo fcmToken
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      print("Error al guardar el token FCM: $e");
    }
  }

  // Login de usuario
  Future<void> loginUser({
    required String email,
    required String password,
    required Function onSuccessAdmin,
    required Function onSuccessUser,
    required Function(String) onError,
    required Function onClearFields,
    required BuildContext context,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        onError('El correo y la contraseña no pueden estar vacíos.');
        onClearFields();
        return;
      }

      authStatus = AuthStatus.checking;
      isLoading = true;
      notifyListeners();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await Future.delayed(Duration(milliseconds: 500));
      }

      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        final userDoc = result.docs.first;
        final userData = userDoc.data() as Map<String, dynamic>?;

        _role = userData?['role'];
        _matricula = userData?['matricula'];
        final userId = userDoc.id;

        // Guarda el token FCM en Firestore en el campo fcmToken
        await _saveDeviceToken(userId);

        authStatus = AuthStatus.authenticated;
        notifyListeners();

        if (_role == 'admin') {
          onSuccessAdmin();
        } else if (_role == 'user') {
          onSuccessUser();
        } else {
          onError('Rol no reconocido para este usuario.');
          onClearFields();
        }
      } else {
        onError('No se encontró un usuario con ese correo.');
        onClearFields();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        onError('No se encontró un usuario con ese correo.');
      } else if (e.code == 'wrong-password') {
        onError('La contraseña es incorrecta.');
      } else {
        onError('Error de autenticación: ${e.message}');
      }
      onClearFields();
    } catch (e) {
      onError('Error desconocido, por favor intenta nuevamente.');
      onClearFields();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Recuperar contraseña
  Future<void> recoverPassword(String email, Function(String) onError) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      onError('Se ha enviado un correo para restablecer la contraseña.');
    } on FirebaseAuthException catch (e) {
      onError('Error: ${e.message}');
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      await _auth.signOut();
      authStatus = AuthStatus.unauthenticated;
      _matricula = null;
      _role = null;
      notifyListeners();
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}
