// lib/src/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double totalAmount;
  final DateTime date;
  final String status;
  final String createdBy;
  // Courier fields
  final String? courierId;
  final String? courierName;
  final String? trackingNumber;

  OrderModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.totalAmount,
    required this.date,
    required this.status,
    required this.createdBy,
    this.courierId,
    this.courierName,
    this.trackingNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'totalAmount': totalAmount,
      'date': Timestamp.fromDate(date),
      'status': status,
      'createdBy': createdBy,
      'courierId': courierId,
      'courierName': courierName,
      'trackingNumber': trackingNumber,
    };
  }

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      items: List<CartItem>.from(
        (data['items'] as List? ?? []).map((x) => CartItem.fromMap(x)),
      ),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'completed',
      createdBy: data['createdBy'] ?? '',
      courierId: data['courierId'],
      courierName: data['courierName'],
      trackingNumber: data['trackingNumber'],
    );
  }
}
