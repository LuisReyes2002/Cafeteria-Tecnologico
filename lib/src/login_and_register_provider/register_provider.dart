import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum RegisterStatus { registering, registered, error, checking }

class RegisterProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RegisterStatus registerStatus = RegisterStatus.error; // Estado inicial
  bool isLoading = false; // Para manejar la carga

  Future<bool> registerUser({
    required String username,
    required String matricula,
    required String password,
    required String tel,
    required String email,
    required Function(String) onError,
    required Function(String) onWarning,
  }) async {
    List<String> errorMessages = [];

    // Validación de la matrícula
    if (!validateMatricula(matricula)) {
      errorMessages.add('La matrícula debe contener exactamente 8 números.');
    }

    // Validación del número de teléfono
    if (!validatePhoneNumber(tel)) {
      errorMessages
          .add('El teléfono debe contener exactamente 10 dígitos sin prefijo.');
    }

    // Validación del correo electrónico
    if (!validateEmail(email)) {
      errorMessages.add(
          'El correo electrónico no es válido. Solo se aceptan cuentas @gmail.com.');
    }

    // Validación de la contraseña (sin espacios)
    if (!validatePassword(password)) {
      errorMessages.add('La contraseña no puede contener espacios.');
    }

    // Verificar si el teléfono, el email y la matrícula ya existen en paralelo
    final phoneExists = await checkPhoneNumberExist(tel);
    if (phoneExists) {
      errorMessages.add('El número de teléfono ya está en uso.');
    }

    final emailExists = await checkEmailExist(email);
    if (emailExists) {
      errorMessages.add('El correo electrónico ya está en uso.');
    }

    final matriculaExists = await checkMatriculaExist(matricula);
    if (matriculaExists) {
      errorMessages.add('La matrícula ya está en uso.');
    }

    final String usernameLowerCase = username.toLowerCase();
    final userExists = await checkUserExist(usernameLowerCase);
    if (userExists) {
      errorMessages.add('El nombre de usuario ya está en uso.');
    }

    // Si hay errores, se envían todos juntos y se retorna false
    if (errorMessages.isNotEmpty) {
      for (String message in errorMessages) {
        onError(message);
      }
      return false;
    }

    // Registro del usuario si no hay errores
    try {
      isLoading = true; // Activar carga
      registerStatus = RegisterStatus.registering;
      notifyListeners();

      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User user = userCredential.user!;
      final String userId = user.uid;

      await _firestore.collection('users').doc(userId).set({
        'username': username,
        'matricula': matricula,
        'tel': tel,
        'email': email,
        'username_lowercase': usernameLowerCase,
        'role': 'user',
      });

      registerStatus = RegisterStatus.registered; // Cambiar estado a registrado
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es muy débil.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Ya hay una cuenta registrada con ese email.';
      } else {
        errorMessage = 'Error desconocido: ${e.message}';
      }
      onError(errorMessage);
    } catch (e) {
      onError('Error desconocido: ${e.toString()}');
    } finally {
      isLoading = false; // Desactivar carga
      notifyListeners();
    }

    return false;
  }

  // Validación de la matrícula
  bool validateMatricula(String matricula) {
    return matricula.length == 8 && RegExp(r'^\d+$').hasMatch(matricula);
  }

  // Validación del número de teléfono
  bool validatePhoneNumber(String tel) {
    return tel.length == 10 && RegExp(r'^\d{10}$').hasMatch(tel);
  }

  // Validación del correo electrónico
  bool validateEmail(String email) {
    return email.endsWith('@gmail.com');
  }

  // Validación de la contraseña (sin espacios)
  bool validatePassword(String password) {
    return !password.contains(' '); // No se permiten espacios en blanco
  }

  // Validación para verificar si la matrícula ya existe
  Future<bool> checkMatriculaExist(String matricula) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('matricula', isEqualTo: matricula)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  // Validación para verificar si el número de teléfono ya existe
  Future<bool> checkPhoneNumberExist(String tel) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('tel', isEqualTo: tel)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  // Validación para verificar si el correo ya existe
  Future<bool> checkEmailExist(String email) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  // Validación para verificar si el nombre de usuario ya existe
  Future<bool> checkUserExist(String usernameLowerCase) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('username_lowercase', isEqualTo: usernameLowerCase)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }
}
