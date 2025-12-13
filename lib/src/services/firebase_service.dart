// lib/src/services/firebase_service.dart
// Basic Firestore helpers (read/write). Urdu+English comments.

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference productsRef() => _db.collection('products');
  CollectionReference salesRef() => _db.collection('sales');
  CollectionReference purchasesRef() => _db.collection('purchases');
  CollectionReference couriersRef() => _db.collection('couriers');

  Future<void> createProduct(Map<String, dynamic> data) async {
    await productsRef().add(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await productsRef().doc(id).update(data);
  }

  // placeholder for stock update (use transactions for safety)
  Future<void> updateStockTransactional(String productId, int delta) async {
    final docRef = productsRef().doc(productId);
    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      final current = (snapshot.get('currentStock') as int?) ?? 0;
      final updated = current + delta;
      tx.update(docRef, {'currentStock': updated});
    });
  }
}
