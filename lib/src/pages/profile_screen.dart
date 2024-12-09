import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:lince_time/src/login_and_register_provider/login_provider.dart';
import 'package:lince_time/src/pages/login_and_register/login/login_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // Si no hay usuario autenticado, redirige a la página de inicio de sesión
    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
      return Container(); // Retorna un contenedor vacío mientras se redirige
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Perfil",
            style: TextStyle(
              color: Colors.white, // Cambia el color del texto a blanco
              fontFamily: 'Roboto', // Cambia esta fuente por la que prefieras
              fontWeight:
                  FontWeight.bold, // Opcional: cambia el peso de la fuente
              fontSize: 20.0, // Opcional: ajusta el tamaño de la fuente
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 5, 150, 0)),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Usa el UID del usuario autenticado
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text("No se encontraron datos del usuario."));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
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
                  controller: TextEditingController(text: userData['username']),
                ),
                const SizedBox(height: 16),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Matrícula',
                    border: OutlineInputBorder(),
                  ),
                  controller:
                      TextEditingController(text: userData['matricula']),
                ),
                const SizedBox(height: 16),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: userData['email']),
                ),
                const SizedBox(height: 16),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Número de celular',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: userData['tel']),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Función para cerrar sesión y redirigir al login
                      Provider.of<LoginProvider>(context, listen: false)
                          .logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child:
                        Text('Cerrar sesión', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
