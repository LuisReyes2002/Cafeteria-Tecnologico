import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:recreo/src/pages/home_screen.dart';
import 'package:recreo/src/pages/cart_screen.dart'; // Importa el CartScreen
import 'package:recreo/src/pages/profile_screen.dart'; // Importa ProfileScreen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(const HomeScreen());
    _pages.add(const FavoriteScreen());
    _pages.add(const CartScreen());
    _pages.add(const ChatScreen());
    _pages.add(ProfileScreen());
  }

  final List<Widget> _navigationItems = [
    Icon(Icons.home_outlined),
    Icon(Icons.favorite_border_outlined),
    Icon(Icons.shopping_basket_outlined),
    Icon(Icons.chat_outlined),
    Icon(Icons.person_3_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Eliminar la AppBar
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color.fromARGB(255, 246, 246, 246),
        items: _navigationItems,
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

// Pantalla Favoritos
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text("Pantalla Favoritos", style: TextStyle(fontSize: 24)));
  }
}

// Pantalla Chat
class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text("Pantalla Chat", style: TextStyle(fontSize: 24)));
  }
}
