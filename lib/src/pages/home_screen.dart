import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Comida';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lince Time"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 4),
            const Text(
              "¿Qué se te antoja hoy?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryLabel('Comida'),
                const SizedBox(width: 20),
                _buildCategoryLabel('Bebida'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              selectedCategory == "Comida" ? "Platillos" : "Bebidas",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _buildFoodGrid(selectedCategory),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLabel(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: selectedCategory == label ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: selectedCategory == label
            ? Colors.blue
            : const Color.fromARGB(255, 224, 224, 224),
      ),
    );
  }

  Widget _buildFoodGrid(String category) {
    String collection = category == 'Comida' ? 'foods' : 'beverages';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final itemList = snapshot.data!.docs.where((item) {
          return item['title']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              item['description']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        }).toList();

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70,
          ),
          itemCount: itemList.length,
          itemBuilder: (context, index) {
            final item = itemList[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.network(
                      item['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("\$${item['price']}"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showProductDetails(item),
                    child: const Text('Comprar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showProductDetails(QueryDocumentSnapshot item) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item['title']),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(item['imageUrl']),
                  const SizedBox(height: 10),
                  Text("Precio: \$${item['price']}"),
                  const SizedBox(height: 10),
                  const Text("Cantidad:"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),
                      Text(quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addToCart(item, quantity);
                Navigator.of(context).pop();
              },
              child: const Text("Agregar al carrito"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  void _addToCart(QueryDocumentSnapshot item, int quantity) {
    CollectionReference cartRef = FirebaseFirestore.instance.collection('cart');
    double total = item['price'] * quantity;
    String matricula = FirebaseAuth.instance.currentUser?.uid ?? '';

    cartRef.add({
      'title': item['title'],
      'imageUrl': item['imageUrl'],
      'price': item['price'],
      'quantity': quantity,
      'total': total,
      'matricula': matricula,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado al carrito')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar al carrito: $error')),
      );
    });
  }
}
