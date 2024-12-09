import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersStatusScreen extends StatefulWidget {
  const OrdersStatusScreen({super.key});

  @override
  _OrdersStatusScreenState createState() => _OrdersStatusScreenState();
}

class _OrdersStatusScreenState extends State<OrdersStatusScreen> {
  final Map<String, bool> _expandedOrders = {};

  @override
  Widget build(BuildContext context) {
    final String? matricula = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Estado de Pedidos",
            style: TextStyle(
              color: Colors.white, // Cambia el color del texto a blanco
              fontFamily: 'Roboto', // Cambia esta fuente por la que prefieras
              fontWeight:
                  FontWeight.bold, // Opcional: cambia el peso de la fuente
              fontSize: 20.0, // Opcional: ajusta el tamaño de la fuente
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 5, 150, 0)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('order_status')
            .where('matricula', isEqualTo: matricula)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No tienes pedidos :)"));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order.id;
              final orderData = order.data() as Map<String, dynamic>;

              final isExpanded = _expandedOrders[orderId] ?? false;

              // Determina el color del fondo dependiendo del estado
              Color orderColor;
              String status = orderData['status'] ?? '';
              if (status == 'Pedido verificado') {
                orderColor = const Color.fromARGB(255, 48, 242, 55);
              } else if (status == 'En preparación') {
                orderColor = const Color.fromARGB(255, 232, 170, 77);
              } else if (status == 'Listo para entregar') {
                orderColor = const Color.fromARGB(255, 54, 219, 244);
              } else {
                orderColor = Colors.grey.withOpacity(0.2);
              }

              return Card(
                margin: const EdgeInsets.all(8.0),
                color: orderColor,
                child: Column(
                  children: [
                    ListTile(
                      title:
                          Text(orderData['username'] ?? 'Usuario Desconocido'),
                      subtitle: Text(
                          "Total: \$${orderData['total'] ?? 'N/A'}\nEstado: ${orderData['status'] ?? 'Desconocido'}"),
                      trailing: IconButton(
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            _expandedOrders[orderId] = !isExpanded;
                          });
                        },
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: List.generate(
                                (orderData['items'] as List).length,
                                (itemIndex) {
                                  final item = orderData['items'][itemIndex];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.shopping_cart,
                                              size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${item['quantity']} x ${item['title']} - \$${item['itemTotal']}",
                                          ),
                                        ],
                                      ),
                                      if (item['selectedGuiso'] != null &&
                                          item['selectedGuiso']!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 22.0),
                                          child: Text(
                                              "Guiso: ${item['selectedGuiso']}",
                                              style: const TextStyle(
                                                  fontStyle: FontStyle.italic)),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                const Icon(Icons.date_range, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  "Fecha: ${orderData['timestamp'] != null ? formatTimestamp(orderData['timestamp']) : 'N/A'}",
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            ElevatedButton(
                              onPressed: () => _confirmDeleteOrder(orderId),
                              child: const Text("Eliminar Pedido"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _confirmDeleteOrder(String orderId) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirmar Eliminación"),
            content: const Text(
                "¿Estás seguro de que deseas eliminar este pedido? Esta acción no se puede deshacer."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      try {
        await FirebaseFirestore.instance
            .collection('order_status')
            .doc(orderId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pedido eliminado exitosamente"),
            duration: const Duration(seconds: 1),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al eliminar el pedido"),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }
}
