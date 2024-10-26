import 'package:flutter/material.dart';

class ManageOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Pedidos'),
      ),
      body: Center(
        child: Text('Aquí se mostrarán y gestionarán los pedidos'),
      ),
    );
  }
}
