import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatusService {
  /// Agrega un nuevo estado de pedido en la colección 'order_status'.
  static Future<void> addOrderStatus(
      String orderId, String status, String message) async {
    // Referencia a la colección 'order_status'
    CollectionReference orderStatusCollection =
        FirebaseFirestore.instance.collection('order_status');

    // Agrega un nuevo documento en 'order_status'
    await orderStatusCollection.add({
      'orderId': orderId, // ID del pedido relacionado
      'status': status, // Estado actual del pedido
      'timestamp': FieldValue.serverTimestamp(), // Marca de tiempo
      'message': message // Mensaje opcional para el usuario
    });
  }
}
