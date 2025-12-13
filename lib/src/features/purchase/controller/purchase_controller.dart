// lib/src/features/purchase/controller/purchase_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/purchase_repository.dart';
import '../../../models/purchase.dart';
import '../../../models/supplier.dart';

class PurchaseController extends StateNotifier<bool> {
  final PurchaseRepository _repository;

  PurchaseController({required PurchaseRepository repository})
      : _repository = repository,
        super(false);

  Future<bool> createSupplier(Supplier supplier, BuildContext context) async {
    state = true;
    try {
      await _repository.createSupplier(supplier);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier added')));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return false;
    } finally {
      if (mounted) state = false;
    }
  }

  Future<bool> createPurchase(Purchase purchase, BuildContext context) async {
    state = true;
    try {
      await _repository.createPurchase(purchase);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase recorded via Stock In')));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return false;
    } finally {
      if (mounted) state = false;
    }
  }
}

final purchaseControllerProvider = StateNotifierProvider<PurchaseController, bool>((ref) {
  return PurchaseController(repository: ref.watch(purchaseRepositoryProvider));
});
