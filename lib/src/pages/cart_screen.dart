import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lince_time/widgets/network_image_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? matricula = FirebaseAuth.instance.currentUser?.uid;
    final TextEditingController specialRequestController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Carrito de compra",
          style: TextStyle(
            color: Colors.white, // Cambia el color del texto a blanco
            fontFamily: 'Roboto', // Cambia esta fuente por la que prefieras
            fontWeight:
                FontWeight.bold, // Opcional: cambia el peso de la fuente
            fontSize: 20.0, // Opcional: ajusta el tamaño de la fuente
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 150, 0),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('matricula', isEqualTo: matricula)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text("Tu carrito está vacío :)."));
          }

          double total = items.fold(0, (sum, item) => sum + item['total']);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final itemData = item.data() as Map<String, dynamic>;
                    bool hasGuiso = itemData.containsKey('selectedGuiso');

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: NetworkImageWidget(
                          imageUrl: item['imageUrl'],
                          width: 50,
                          height: 50,
                        ),
                        title: Text(item['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Cantidad: ${item['quantity']}"),
                            if (hasGuiso)
                              Text("Guiso: ${itemData['selectedGuiso']}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("\$${item['total']}"),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteItem(item.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Total: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: specialRequestController,
                  decoration: const InputDecoration(
                    labelText: "Comentarios especiales (opcional)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _confirmPurchase(
                    context,
                    total,
                    matricula,
                    specialRequestController.text,
                  );
                },
                child: const Text("Confirmar Compra"),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  void _deleteItem(String itemId) {
    FirebaseFirestore.instance.collection('cart').doc(itemId).delete();
  }

  void _confirmPurchase(BuildContext context, double total, String? matricula,
      String specialRequest) {
    if (matricula == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Debes iniciar sesión para confirmar la compra.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar Compra"),
          content: Text(
              "El total de tu compra es: \$${total.toStringAsFixed(2)}. ¿Estás seguro de que deseas continuar?"),
          actions: [
            TextButton(
              onPressed: () async {
                await _saveOrder(matricula, total, specialRequest);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Compra confirmada"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Text("Sí"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveOrder(
      String? matricula, double total, String specialRequest) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(matricula)
          .get();

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null) {
        final items = await FirebaseFirestore.instance
            .collection('cart')
            .where('matricula', isEqualTo: matricula)
            .get();

        final List<Map<String, dynamic>> itemList = items.docs.map((item) {
          return {
            'title': item['title'],
            'quantity': item['quantity'],
            'total': item['total'],
            'itemTotal': item['total'],
            'selectedGuiso': item['selectedGuiso'],
          };
        }).toList();

        final orderRef =
            await FirebaseFirestore.instance.collection('orders').add({
          'matricula': matricula,
          'username': userData['username'],
          'tel': userData['tel'],
          'total': total,
          'specialRequest': specialRequest,
          'items': itemList,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'Pedido Enviado', // Aquí se agrega el estado
        });

        // Guardar en 'order_status' con el estado 'Pedido Enviado'
        await FirebaseFirestore.instance.collection('order_status').add({
          'username': userData['username'],
          'matricula': matricula,
          'total': total,
          'orderId': orderRef.id,
          'status': 'Pedido Enviado',
          'items': itemList,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Enviar notificación a los administradores
        sendNotificationToAdmins(orderRef.id);

        // Eliminar los productos del carrito
        for (var item in items.docs) {
          _deleteItem(item.id);
        }
      }
    } catch (e) {
      print('Error al guardar el pedido: $e');
    }
  }

  void sendNotificationToAdmins(String orderId) async {
    FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        String? fcmToken = doc['fcmToken'];

        if (fcmToken != null && fcmToken.isNotEmpty) {
          // Aquí podrías enviar la notificación a través de Firebase Messaging
          print("Enviando notificación al admin con token: $fcmToken");

          // Llama al método para enviar la notificación a los administradores
          // Ejemplo: NotificationService.showNotification(
          //   id: 1,
          //   title: 'Nuevo Pedido',
          //   body: '¡Tienes un nuevo pedido con ID: $orderId!',
          // );
        }
      }
    });
  }
}
