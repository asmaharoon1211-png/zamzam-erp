// lib/src/models/purchase.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class Purchase {
  final String id;
  final String supplierId;
  final String supplierName;
  final DateTime date;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final String createdBy;

  Purchase({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'supplierId': supplierId,
      'supplierName': supplierName,
      'date': Timestamp.fromDate(date),
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdBy': createdBy,
    };
  }

  factory Purchase.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Purchase(
      id: doc.id,
      supplierId: data['supplierId'] ?? '',
      supplierName: data['supplierName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      items: List<CartItem>.from(
        (data['items'] as List? ?? []).map((x) => CartItem.fromMap(x)),
      ),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'completed',
      createdBy: data['createdBy'] ?? '',
    );
  }
}
