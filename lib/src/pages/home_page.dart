import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:lince_time/src/pages/cart_screen.dart';
import 'package:lince_time/src/pages/home_screen.dart';
import 'package:lince_time/src/pages/profile_screen.dart';
import 'package:lince_time/src/pages/OrderStatusScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const CartScreen(),
      OrdersStatusScreen(), // Cambia por el ID real
      ProfileScreen(),
    ];
  }

  final List<Widget> _navigationItems = [
    const Icon(Icons.home_outlined),
    const Icon(Icons.shopping_cart_sharp),
    const Icon(Icons.receipt_long), // Cambia a un ícono de "pedido"
    const Icon(Icons.person_3_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color.fromARGB(220, 12, 99, 10),
        items: [
          Icon(
            Icons.home_rounded,
            color: _pageIndex == 0
                ? Colors.white
                : Colors.black, // Icon color changes based on selection
          ),
          Icon(
            Icons.shopping_cart_sharp,
            color: _pageIndex == 1 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.receipt_long,
            color: _pageIndex == 2 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.person_2_rounded,
            color: _pageIndex == 3 ? Colors.white : Colors.black,
          ),
        ],
        height: 75,
        buttonBackgroundColor: const Color.fromARGB(255, 7, 120, 4),
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
