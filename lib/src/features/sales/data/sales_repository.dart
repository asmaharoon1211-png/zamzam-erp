// lib/src/features/sales/data/sales_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/order_model.dart';
import '../../auth/data/auth_repository.dart';

class SalesRepository {
  final FirebaseFirestore _firestore;

  SalesRepository(this._firestore);

  CollectionReference get _ordersRef => _firestore.collection('sales');
  CollectionReference get _productsRef => _firestore.collection('products');

  Stream<List<OrderModel>> streamOrders() {
    return _ordersRef.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromDoc(doc)).toList();
    });
  }

  Future<void> createOrder(OrderModel order) async {
    await _firestore.runTransaction((transaction) async {
      // 1. Check stock for all items
      for (final item in order.items) {
        final productDocRef = _productsRef.doc(item.productId);
        final productSnapshot = await transaction.get(productDocRef);

        if (!productSnapshot.exists) {
          throw Exception('Product ${item.productName} does not exist!');
        }

        final currentStock = (productSnapshot.get('currentStock') as int?) ?? 0;
        if (currentStock < item.qty) {
          throw Exception('Insufficient stock for ${item.productName}. Available: $currentStock');
        }

        // 2. Deduct stock
        final newStock = currentStock - item.qty;
        transaction.update(productDocRef, {'currentStock': newStock});
      }

      // 3. Create order
      final newOrderDoc = _ordersRef.doc(); // Auto-ID
      transaction.set(newOrderDoc, order.toMap());
    });
  }
}

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(FirebaseFirestore.instance);
});

final salesStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(salesRepositoryProvider).streamOrders();
});
