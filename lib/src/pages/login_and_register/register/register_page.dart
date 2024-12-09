import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lince_time/src/login_and_register_provider/register_provider.dart';
import 'package:lince_time/src/pages/login_and_register/register/verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false; // Estado de carga

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true; // Iniciar carga
    });

    final registerProvider =
        Provider.of<RegisterProvider>(context, listen: false);
    bool success = await registerProvider.registerUser(
      username: usernameController.text,
      matricula: matriculaController.text,
      password: passwordController.text,
      tel: telController.text,
      email: emailController.text,
      onError: (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      },
      onWarning: (warning) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(warning)));
      },
    );

    setState(() {
      _isLoading = false; // Detener carga
    });

    if (success) {
      // Redirigir a la página de verificación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VerificationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Nombre de Usuario'),
            ),
            TextField(
              controller: matriculaController,
              decoration: const InputDecoration(labelText: 'Matrícula'),
              keyboardType: TextInputType.number,
              maxLength: 8,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
            ),
            TextField(
              controller: telController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Botón de registro
            ElevatedButton(
              onPressed: _isLoading ? null : _registerUser,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
