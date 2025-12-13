// lib/src/features/inventory/controller/inventory_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inventory_repository.dart';
import '../../../models/product.dart';

class InventoryController extends StateNotifier<bool> {
  final InventoryRepository _repository;

  InventoryController({required InventoryRepository repository})
      : _repository = repository,
        super(false);

  Future<String?> uploadImage(File file) async {
    try {
      final fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await _repository.uploadImage(file, fileName);
    } catch (e) {
      // Handle error quietly or rethrow, UI will handle success/fail of main action
      return null;
    }
  }

  Future<bool> addProduct(Product product, File? imageFile, BuildContext context) async {
    state = true;
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
      }

      final newProduct = Product(
        id: product.id,
        name: product.name,
        sku: product.sku,
        category: product.category,
        purchasePrice: product.purchasePrice,
        salePrice: product.salePrice,
        currentStock: product.currentStock,
        minStock: product.minStock,
        unit: product.unit,
        description: product.description,
        imageUrl: imageUrl ?? product.imageUrl,
        createdAt: product.createdAt,
      );

      await _repository.createProduct(newProduct);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      }
      return false;
    } finally {
      if (mounted) state = false;
    }
  }

  Future<void> deleteProduct(String id, BuildContext context) async {
    try {
      await _repository.deleteProduct(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting product: $e')),
        );
      }
    }
  }
}

final inventoryControllerProvider = StateNotifierProvider<InventoryController, bool>((ref) {
  return InventoryController(
    repository: ref.watch(inventoryRepositoryProvider),
  );
});
