import 'package:flutter/material.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Por favor verifica tu correo electrónico.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar lógica para regresar a la página de inicio de sesión o verificar el estado del correo
                Navigator.pop(context);
              },
              child: const Text('Regresar a Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
