// lib/src/features/couriers/data/courier_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/courier.dart';

class CourierRepository {
  final FirebaseFirestore _firestore;

  CourierRepository(this._firestore);

  CollectionReference get _couriersRef => _firestore.collection('couriers');

  Future<void> createCourier(Courier courier) async {
    await _couriersRef.add(courier.toMap());
  }

  Future<void> updateCourier(String id, Courier courier) async {
    await _couriersRef.doc(id).update(courier.toMap());
  }

  Future<void> deleteCourier(String id) async {
    await _couriersRef.doc(id).delete();
  }

  Stream<List<Courier>> streamCouriers() {
    return _couriersRef.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Courier.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }
}

final courierRepositoryProvider = Provider<CourierRepository>((ref) {
  return CourierRepository(FirebaseFirestore.instance);
});

final couriersStreamProvider = StreamProvider<List<Courier>>((ref) {
  return ref.watch(courierRepositoryProvider).streamCouriers();
});
