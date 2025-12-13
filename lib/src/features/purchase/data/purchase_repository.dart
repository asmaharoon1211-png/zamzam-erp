// lib/src/features/purchase/data/purchase_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/purchase.dart';
import '../../../models/supplier.dart';

class PurchaseRepository {
  final FirebaseFirestore _firestore;

  PurchaseRepository(this._firestore);

  CollectionReference get _purchasesRef => _firestore.collection('purchases');
  CollectionReference get _suppliersRef => _firestore.collection('suppliers');
  CollectionReference get _productsRef => _firestore.collection('products');

  // Suppliers
  Stream<List<Supplier>> streamSuppliers() {
    return _suppliersRef.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Supplier.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> createSupplier(Supplier supplier) async {
    await _suppliersRef.add(supplier.toMap());
  }

  // Purchases (Stock In)
  Stream<List<Purchase>> streamPurchases() {
    return _purchasesRef.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Purchase.fromDoc(doc)).toList();
    });
  }

  Future<void> createPurchase(Purchase purchase) async {
    await _firestore.runTransaction((transaction) async {
      // 1. Update stock for all items (INCREMENT)
      for (final item in purchase.items) {
        final productDocRef = _productsRef.doc(item.productId);
        final productSnapshot = await transaction.get(productDocRef);

        if (!productSnapshot.exists) {
          throw Exception('Product ${item.productName} does not exist!');
        }

        final currentStock = (productSnapshot.get('currentStock') as int?) ?? 0;
        final newStock = currentStock + item.qty; // Buying means adding stock
        
        transaction.update(productDocRef, {'currentStock': newStock});
      }

      // 2. Create purchase doc
      final newPurchaseDoc = _purchasesRef.doc();
      transaction.set(newPurchaseDoc, purchase.toMap());
    });
  }
}

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepository(FirebaseFirestore.instance);
});

final suppliersStreamProvider = StreamProvider<List<Supplier>>((ref) {
  return ref.watch(purchaseRepositoryProvider).streamSuppliers();
});

final purchasesStreamProvider = StreamProvider<List<Purchase>>((ref) {
  return ref.watch(purchaseRepositoryProvider).streamPurchases();
});
