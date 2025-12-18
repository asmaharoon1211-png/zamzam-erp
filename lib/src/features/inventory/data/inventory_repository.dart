// lib/src/features/inventory/data/inventory_repository.dart
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/product.dart';

class InventoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  InventoryRepository(this._firestore, this._storage);

  CollectionReference get _productsRef => _firestore.collection('products');

  // Create
  Future<void> createProduct(Product product) async {
    await _productsRef.add(product.toMap());
  }

  // Update
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _productsRef.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete
  Future<void> deleteProduct(String id) async {
    await _productsRef.doc(id).delete();
  }

  // Upload Image
  Future<String> uploadImage(XFile file, String path) async {
    final ref = _storage.ref().child(path);
    final data = await file.readAsBytes();
    final uploadTask = ref.putData(data, SettableMetadata(contentType: 'image/jpeg')); 
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Read Stream
  Stream<List<Product>> streamProducts() {
    return _productsRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromDoc(doc)).toList();
    });
  }

  // Read Single
  Future<Product?> getProduct(String id) async {
    final doc = await _productsRef.doc(id).get();
    if (doc.exists) {
      return Product.fromDoc(doc);
    }
    return null;
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.streamProducts();
});
