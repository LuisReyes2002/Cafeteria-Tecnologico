import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
          title: const Text(
            "Lince Time",
            style: TextStyle(
              color: Colors.white, // Cambia el color del texto a blanco
              fontFamily: 'Roboto', // Cambia esta fuente por la que prefieras
              fontWeight:
                  FontWeight.bold, // Opcional: cambia el peso de la fuente
              fontSize: 20.0, // Opcional: ajusta el tamaño de la fuente
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 5, 150, 0)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título con la fuente Bukhari Script
            const Text(
              "¿Qué se te antoja hoy?",
              style: TextStyle(
                fontFamily: 'Bukhari Script',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 22, 1), // color verde
              ),
            ),
            const SizedBox(height: 10),
            // Buscador con icono de búsqueda y caja de texto verde degradado
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: TextStyle(
                  fontFamily: 'Bukhari Script',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.green.withOpacity(0.2),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 4),
            // Filtro de categorías
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryLabel('Comida'),
                const SizedBox(width: 20),
                _buildCategoryLabel('Bebida'),
              ],
            ),
            const SizedBox(height: 4),
            // Título de platillos con fuente Bukhari Script
            Text(
              selectedCategory == "Comida" ? "Platillos" : "Bebidas",
              style: const TextStyle(
                fontFamily: 'Bukhari Script',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // Grilla de alimentos
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
            fontFamily: 'Bukhari Script', // Fuente personalizada
          ),
        ),
        backgroundColor: selectedCategory == label
            ? const Color.fromARGB(255, 5, 150, 0)
            : const Color.fromARGB(255, 224, 224, 224),
      ),
    );
  }

  Widget _buildFoodGrid(String category) {
    String collection = category == 'Comida' ? 'foods' : 'beverages';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final itemList = snapshot.data!.docs.where((item) {
          return item['title']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) &&
              item['isHidden'] == true;
        }).toList();

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.80,
          ),
          itemCount: itemList.length,
          itemBuilder: (context, index) {
            final item = itemList[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        item['imageUrl'],
                        fit: BoxFit.cover,
                      ),
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
                            fontFamily: 'Bukhari Script',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\$${item['price']}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _showProductDetails(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50), // Verde
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Comprar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white, // Texto blanco
                        ),
                      ),
                    ),
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
    List<String> guisos = [];
    String? selectedGuiso;

    if (item.data() != null &&
        (item.data() as Map<String, dynamic>)
            .containsKey('guisos_adicionales')) {
      guisos = List<String>.from(item['guisos_adicionales'])
          .where((guiso) => guiso.isNotEmpty)
          .toList();
    }

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
                          if (quantity < 5) {
                            // Limitar a 5
                            setState(() {
                              quantity++;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'No puedes agregar más de 5 productos')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  if (guisos.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Selecciona un guiso:"),
                        DropdownButton<String>(
                          value: selectedGuiso,
                          items: guisos.map((guiso) {
                            return DropdownMenuItem(
                              value: guiso,
                              child: Text(guiso),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedGuiso = newValue;
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
                _addToCart(item, quantity, selectedGuiso);
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

  void _addToCart(
      QueryDocumentSnapshot item, int quantity, String? selectedGuiso) {
    CollectionReference cartRef = FirebaseFirestore.instance.collection('cart');
    double total = item['price'] * quantity;
    String matricula = FirebaseAuth.instance.currentUser?.uid ?? '';

    cartRef.add({
      'title': item['title'],
      'imageUrl': item['imageUrl'],
      'price': item['price'],
      'quantity': quantity,
      'selectedGuiso': selectedGuiso ?? '',
      'total': total,
      'matricula': matricula,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Producto agregado al carrito'),
          duration: const Duration(seconds: 1), // Duración más corta
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar al carrito: $error'),
          duration:
              const Duration(seconds: 1), // Duración más corta en caso de error
        ),
      );
    });
  }
}
