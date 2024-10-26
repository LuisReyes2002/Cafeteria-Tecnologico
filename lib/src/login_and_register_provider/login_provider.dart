import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthStatus { authenticated, unauthenticated, checking }

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instancia de FirebaseAuth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthStatus authStatus = AuthStatus.unauthenticated;
  bool isLoading = false; // Agregado para manejar la carga
  String? _matricula; // Variable para almacenar la matrícula
  String? get matricula => _matricula;

  // Verifica si el usuario ya está autenticado
  Future<void> checkIfUserIsAuthenticated() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Si ya está autenticado, cambia el estado
      authStatus = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
    required Function onSuccessAdmin,
    required Function onSuccessUser,
    required Function(String) onError,
    required Function onClearFields,
  }) async {
    try {
      // Verifica si el usuario ya está autenticado
      User? user = _auth.currentUser;
      if (user != null) {
        onSuccessUser(); // Redirige si ya está autenticado
        return;
      }

      authStatus = AuthStatus.checking;
      isLoading = true; // Activar carga
      notifyListeners();

      // Validar email y contraseña
      if (email.isEmpty || password.isEmpty) {
        onError('El correo y la contraseña no pueden estar vacíos.');
        onClearFields();
        return;
      }

      try {
        // Intentar iniciar sesión con las credenciales proporcionadas
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Si se inicia sesión correctamente
        if (userCredential.user != null) {
          authStatus = AuthStatus.authenticated;
          notifyListeners();

          // Obtener el rol del usuario
          final QuerySnapshot result = await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (result.docs.isNotEmpty) {
            final userDoc = result.docs.first;
            final String role = userDoc.get('role');
            _matricula = userDoc.get('matricula');
            if (role == 'admin') {
              onSuccessAdmin();
            } else if (role == 'user') {
              onSuccessUser();
            }
          } else {
            onError('No se encontró un usuario con ese correo.');
            onClearFields();
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'wrong-password':
            errorMessage = 'La contraseña es incorrecta.';
            break;
          case 'user-not-found':
            errorMessage = 'No se encontró un usuario con ese correo.';
            break;
          case 'invalid-email':
            errorMessage = 'El correo electrónico es inválido.';
            break;
          case 'operation-not-allowed':
            errorMessage =
                'El inicio de sesión con correo electrónico está deshabilitado.';
            break;
          default:
            errorMessage = 'Error de autenticación: ${e.message}';
        }
        onError(errorMessage);
        onClearFields();
      }
    } on FirebaseException catch (e) {
      onError('Error de Firestore: ${e.message}');
      onClearFields();
    } catch (e) {
      onError('Error desconocido, por favor intenta nuevamente.');
      onClearFields();
    } finally {
      isLoading = false; // Desactivar carga
      notifyListeners();
    }
  }

  // Función para enviar correo de recuperación de contraseña
  Future<void> recoverPassword(String email, Function(String) onError) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Mensaje de éxito (puedes usar un snackbar o dialog)
      onError('Se ha enviado un correo para restablecer la contraseña.');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No se encontró un usuario con ese correo.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo electrónico es inválido.';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }
      onError(errorMessage);
    }
  }

  // Función para cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
