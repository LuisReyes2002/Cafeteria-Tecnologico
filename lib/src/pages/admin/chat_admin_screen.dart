import 'package:flutter/material.dart';

class ChatAdminScreen extends StatelessWidget {
  const ChatAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensajería con Usuarios"),
        backgroundColor: Colors.tealAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                // Aquí se pueden listar los mensajes entre el administrador y los usuarios
                ListTile(
                  title: Text("Mensaje del Administrador"),
                  subtitle: Text("Aquí irá el contenido del mensaje..."),
                ),
                ListTile(
                  title: Text("Mensaje del Usuario"),
                  subtitle: Text("Aquí irá el contenido del mensaje..."),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Aquí agregarás la funcionalidad para enviar mensajes
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
