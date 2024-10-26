import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recreo/src/login_and_register_provider/login_provider.dart';
import 'package:recreo/src/pages/login_and_register/login/login_page.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Datos de perfil de ejemplo, en un proyecto real vendrán de Firebase
    final profileData = {
      'email': 'xavirey010@gmail.com',
      'matricula': '20010142',
      'role': 'admin',
      'tel': '6771072863',
      'username': 'Javier',
      'username_lowercase': 'javier'
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: profileData['username']),
            ),
            SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Matrícula',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: profileData['matricula']),
            ),
            SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: profileData['email']),
            ),
            SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Número de celular',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: profileData['tel']),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Función para cerrar sesión y redirigir al login
                  Provider.of<LoginProvider>(context, listen: false).logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Cerrar sesión', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
