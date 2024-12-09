import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de tener esta importación

class ManageOrdersScreen extends StatefulWidget {
  @override
  _ManageOrdersScreenState createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final Set<String> _expandedOrders = {}; // Para manejar pedidos expandidos
  final Map<String, String> _orderStatuses =
      {}; // Mapa para los estados de los pedidos

  Future<void> _sendSMSWithPermission(
      BuildContext context, String message, List<String> recipients) async {
    try {
      PermissionStatus status = await Permission.sms.request();

      if (!status.isGranted) {
        _showAlert(context, 'Error',
            'Permiso de SMS denegado. Habilítalo en la configuración.');
        return;
      }

      String result = await sendSMS(message: message, recipients: recipients);
      _showAlert(context, 'Éxito', 'Mensaje enviado correctamente.');
      print('Resultado: $result');
    } catch (e) {
      print('Error al enviar SMS: $e');
      _showAlert(context, 'Error', 'Error al enviar el SMS.');
    }
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(String orderId, String status) async {
    setState(() {
      _orderStatuses[orderId] = status;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(orderId, status);

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': status});

    final orderStatusRef = await FirebaseFirestore.instance
        .collection('order_status')
        .where('orderId', isEqualTo: orderId)
        .get();

    for (var doc in orderStatusRef.docs) {
      await doc.reference.update({
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Estado del pedido actualizado a '$status'"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _deleteOrder(String orderId) async {
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
                child:
                    const Text("Eliminar", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pedido eliminado exitosamente"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Color _getCardColor(String orderId) {
    final status = _orderStatuses[orderId];

    if (status == 'Pedido verificado') {
      return Color.fromARGB(255, 3, 221, 11);
    } else if (status == 'En preparación') {
      return Color.fromARGB(255, 238, 255, 0);
    } else if (status == 'Listo para entregar') {
      return Color.fromARGB(255, 80, 169, 241);
    } else {
      return Colors.white;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOrderStatuses();
  }

  Future<void> _loadOrderStatuses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .orderBy('timestamp', descending: false)
        .get();

    for (var order in ordersSnapshot.docs) {
      final orderId = order.id;
      final storedStatus = prefs.getString(orderId);
      if (storedStatus != null) {
        setState(() {
          _orderStatuses[orderId] = storedStatus;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
        backgroundColor: const Color.fromARGB(255, 53, 200, 220),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order.id;
              final orderData = order.data() as Map<String, dynamic>;
              final items = (orderData['items'] as List<dynamic>? ?? [])
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
              final isExpanded = _expandedOrders.contains(orderId);

              return Card(
                margin: const EdgeInsets.all(8.0),
                color: _getCardColor(orderId),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                          "Pedido ${index + 1} - ${orderData['username'] ?? 'Desconocido'}"),
                      subtitle: Text("Total: \$${orderData['total'] ?? 'N/A'}"),
                      trailing: IconButton(
                        icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more),
                        onPressed: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedOrders.remove(orderId);
                            } else {
                              _expandedOrders.add(orderId);
                            }
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
                            // Teléfono y botón de mensaje
                            Row(
                              children: [
                                Icon(Icons.phone, size: 18),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "Tel: ${orderData['tel'] ?? 'N/A'}",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.message),
                                  onPressed: () {
                                    final phoneNumber = orderData['tel'] ?? '';
                                    if (phoneNumber.isNotEmpty) {
                                      _sendSMSWithPermission(
                                          context,
                                          'Tu pedido ya está listo',
                                          [phoneNumber]);
                                    }
                                  },
                                ),
                              ],
                            ),

                            // Fecha del pedido
                            Row(
                              children: [
                                Icon(Icons.date_range, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  "Fecha: ${orderData['timestamp'] != null ? (orderData['timestamp'] as Timestamp).toDate() : 'N/A'}",
                                ),
                              ],
                            ),

                            const SizedBox(height: 8.0),

                            // Título: Artículos
                            Row(
                              children: [
                                Icon(Icons.shopping_cart, size: 18),
                                const SizedBox(width: 4),
                                const Text("Artículos:"),
                              ],
                            ),

                            // Lista de artículos con chips
                            Wrap(
                              spacing: 4,
                              children: items.map((item) {
                                final guiso = item['selectedGuiso'] ?? '';
                                final hasGuiso =
                                    guiso.isNotEmpty; // Indica si tiene guiso
                                final precio = item['itemTotal'] ??
                                    0; // Precio individual del producto
                                final cantidad = item['quantity'] ??
                                    1; // Cantidad de productos

                                // Precio total para ese producto
                                final precioTotal = precio * cantidad;

                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                            item['title'] ?? 'Desconocido'),
                                        content: Text(
                                          "Cantidad: $cantidad\n"
                                          "Precio por unidad: \$${precio.toStringAsFixed(2)}\n"
                                          "Precio total: \$${precioTotal.toStringAsFixed(2)}"
                                          "${hasGuiso ? '\nGuiso: $guiso' : '\nSin guiso'}",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cerrar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Chip(
                                    label: Text(
                                      "${item['title'] ?? 'Producto'} (\$${precio.toStringAsFixed(2)} x $cantidad) = \$${precioTotal.toStringAsFixed(2)}",
                                    ),
                                    backgroundColor: hasGuiso
                                        ? Colors.orange
                                        : Colors.lightBlue,
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 8.0),

                            // Nota especial
                            if (orderData['specialRequest'] != null &&
                                orderData['specialRequest'].isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.edit_note,
                                      size: 18, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "Nota: ${orderData['specialRequest']}",
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 8.0),

                            // Cambio de estado del pedido
                            Row(
                              children: [
                                Icon(Icons.check_circle, size: 18),
                                const SizedBox(width: 4),
                                DropdownButton<String>(
                                  value: _orderStatuses[orderId],
                                  onChanged: (newStatus) {
                                    if (newStatus != null) {
                                      _updateOrderStatus(orderId, newStatus);
                                    }
                                  },
                                  items: <String>[
                                    'Pedido verificado',
                                    'En preparación',
                                    'Listo para entregar',
                                  ].map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const Divider(),
                    ButtonBar(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteOrder(orderId);
                          },
                        ),
                      ],
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
}
