import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteItems = snapshot.data!.docs;

          if (favoriteItems.isEmpty) {
            return const Center(child: Text("No tienes favoritos aún."));
          }

          return ListView.builder(
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              final item = favoriteItems[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(item['imageUrl']),
                  title: Text(item['title']),
                  subtitle: Text("\$${item['price']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          _addToCart(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _removeFromFavorites(item.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addToCart(QueryDocumentSnapshot item) {
    CollectionReference cartRef = FirebaseFirestore.instance.collection('cart');
    String matricula = FirebaseAuth.instance.currentUser?.uid ?? '';

    cartRef.add({
      'title': item['title'],
      'imageUrl': item['imageUrl'],
      'price': item['price'],
      'quantity': 1,
      'total': item['price'],
      'matricula': matricula,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Producto agregado al carrito desde favoritos')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar al carrito: $error')),
      );
    });
  }

  void _removeFromFavorites(String favoriteId) {
    FirebaseFirestore.instance.collection('favorites').doc(favoriteId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado de favoritos')),
    );
  }
}
