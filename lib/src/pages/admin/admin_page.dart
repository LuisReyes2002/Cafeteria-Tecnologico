import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:lince_time/src/pages/admin/manage_food_screen.dart';
import 'package:lince_time/src/pages/admin/manage_bebidas_screen.dart';
import 'package:lince_time/src/pages/admin/manage_orders_screen.dart';
//import 'package:lince_time/src/pages/admin/prueba.dart'; // Nueva pantalla de pedidos

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
    ManageBeverageScreen(), // Pantalla para gestionar bebidas
    ManageOrdersScreen(),
    // PruebaPage(), // Pantalla para gestionar pedidos
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color.fromARGB(255, 50, 186, 203),
        items: [
          Icon(
            Icons.fastfood,
            color: _pageIndex == 0
                ? Colors.white
                : Colors.black, // White when selected, black otherwise
          ),
          Icon(
            Icons.local_drink,
            color: _pageIndex == 1 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.shopping_bag,
            color: _pageIndex == 2 ? Colors.white : Colors.black,
          ),
          //Icon(
          //Icons.abc,
          //color: _pageIndex == 3 ? Colors.white : Colors.black,
          //,
        ],
        height: 75,
        buttonBackgroundColor: const Color.fromARGB(255, 53, 200, 220),
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
