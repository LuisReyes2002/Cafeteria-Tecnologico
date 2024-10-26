import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:recreo/src/login_and_register_provider/login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true; // Control para mostrar/ocultar contraseña

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Inicio de Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
            ),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              onChanged: (value) {
                if (value.contains(' ')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('La contraseña no puede contener espacios.')),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            if (loginProvider.isLoading) // Mostrar carga
              CircularProgressIndicator(),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance
                    .currentUser; // Verifica si el usuario está autenticado

                if (user != null) {
                  // El usuario ya está autenticado
                  Navigator.pushReplacementNamed(context, '/home');
                  return;
                }

                // Intenta iniciar sesión
                loginProvider.loginUser(
                  email: emailController.text,
                  password: passwordController.text,
                  onSuccessAdmin: () {
                    Navigator.pushReplacementNamed(context, '/admin');
                  },
                  onSuccessUser: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  onError: (errorMessage) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  },
                  onClearFields: () {
                    emailController.clear();
                    passwordController.clear();
                  },
                );
              },
              child: Text('Iniciar Sesión'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('¿No tienes una cuenta? Regístrate aquí.'),
            ),
            TextButton(
              onPressed: () async {
                String email = emailController.text;
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Por favor ingresa tu correo electrónico.')),
                  );
                  return;
                }
                await loginProvider.recoverPassword(
                  email,
                  (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                );
              },
              child: Text('¿Olvidaste tu contraseña?'),
            ),
          ],
        ),
      ),
    );
  }
}
