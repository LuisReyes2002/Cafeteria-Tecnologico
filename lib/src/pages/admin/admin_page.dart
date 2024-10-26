import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:recreo/src/pages/admin/chat_admin_screen.dart';
import 'package:recreo/src/pages/admin/manage_food_screen.dart';
import 'package:recreo/src/pages/admin/manage_bebidas_screen.dart';
import 'package:recreo/src/pages/admin/manage_orders_screen.dart'; // Nueva pantalla de pedidos

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _pageIndex = 0;

  // Lista de pantallas para cada sección administrativa
  final List<Widget> _pages = [
    ManageFoodScreen(), // Pantalla para gestionar platillos
    ManageBeveragesScreen(), // Pantalla para gestionar bebidas
    ChatAdminScreen(), // Pantalla para enviar mensajes
    ManageOrdersScreen(), // Pantalla para gestionar pedidos
  ];

  final List<Widget> _navigationItem = [
    Icon(Icons.fastfood_outlined), // Icono para comida
    Icon(Icons.local_drink_outlined), // Icono para bebidas
    Icon(Icons.message_outlined), // Icono para mensajes
    Icon(Icons.shopping_bag_outlined), // Icono para pedidos
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color.fromARGB(255, 246, 246, 246),
        items: _navigationItem,
        height: 75,
        buttonBackgroundColor: Colors.tealAccent,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
