// lib/src/models/product.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double purchasePrice;
  final double salePrice;
  final int currentStock;
  final int minStock;
  final String unit;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.purchasePrice,
    required this.salePrice,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      sku: data['sku'] ?? '',
      category: data['category'] ?? '',
      purchasePrice: (data['purchasePrice'] ?? 0).toDouble(),
      salePrice: (data['salePrice'] ?? 0).toDouble(),
      currentStock: (data['currentStock'] ?? 0).toInt(),
      minStock: (data['minStock'] ?? 0).toInt(),
      unit: data['unit'] ?? '',
      description: data['description'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'category': category,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'currentStock': currentStock,
      'minStock': minStock,
      'unit': unit,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
