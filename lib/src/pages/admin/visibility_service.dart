// visibility_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class VisibilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to toggle visibility
  Future<void> toggleVisibility(String foodId, bool currentVisibility) async {
    bool newVisibility = !currentVisibility;
    await _firestore.collection('foods').doc(foodId).update({
      'isHidden': newVisibility,
    });
  }

  // Method to set visibility directly
  Future<void> setVisibility(String foodId, bool isHidden) async {
    await _firestore.collection('foods').doc(foodId).update({
      'isHidden': isHidden,
    });
  }
}
