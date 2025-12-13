// lib/src/features/sales/controller/cart_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/cart_item.dart';
import '../../../models/order_model.dart';
import '../../../models/product.dart';
import '../data/sales_repository.dart';
import '../../auth/data/auth_repository.dart';

class CartState {
  final List<CartItem> items;
  final bool isLoading;

  const CartState({this.items = const [], this.isLoading = false});

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get tax => subtotal * 0.0; // 0% tax for now, configurable later
  double get total => subtotal + tax;
  
  CartState copyWith({List<CartItem>? items, bool? isLoading}) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CartController extends StateNotifier<CartState> {
  final SalesRepository _repository;
  final Ref _ref;

  CartController(this._repository, this._ref) : super(const CartState());

  void addToCart(Product product) {
    if (state.isLoading) return;

    final existingIndex = state.items.indexWhere((i) => i.productId == product.id);
    if (existingIndex >= 0) {
      // Increment qty
      final existingItem = state.items[existingIndex];
      // Check stock limit
      if (existingItem.qty >= product.currentStock) {
        // Handle max stock reached (could return result or show snackbar via UI listener)
        return;
      }

      final updatedItem = CartItem(
        productId: existingItem.productId,
        productName: existingItem.productName,
        price: existingItem.price,
        qty: existingItem.qty + 1,
      );
      
      final newItems = [...state.items];
      newItems[existingIndex] = updatedItem;
      state = state.copyWith(items: newItems);
    } else {
      if (product.currentStock <= 0) return;
      
      final newItem = CartItem(
        productId: product.id,
        productName: product.name,
        price: product.salePrice,
        qty: 1,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void removeFromCart(CartItem item) {
    final newItems = state.items.where((i) => i.productId != item.productId).toList();
    state = state.copyWith(items: newItems);
  }

  void decrementQty(CartItem item) {
    if (item.qty > 1) {
      final index = state.items.indexOf(item);
      if (index >= 0) {
         final updatedItem = CartItem(
            productId: item.productId,
            productName: item.productName,
            price: item.price,
            qty: item.qty - 1,
          );
          final newItems = [...state.items];
          newItems[index] = updatedItem;
          state = state.copyWith(items: newItems);
      }
    } else {
      removeFromCart(item);
    }
  }

  void clearCart() {
    state = state.copyWith(items: []);
  }

  Future<bool> checkout(BuildContext context, {String? courierId, String? courierName}) async {
    if (state.items.isEmpty) return false;
    
    state = state.copyWith(isLoading: true);
    try {
      final user = _ref.read(authRepositoryProvider).currentUser;
      
      final order = OrderModel(
        id: '', // Auto-gen
        items: state.items,
        subtotal: state.subtotal,
        tax: state.tax,
        totalAmount: state.total,
        date: DateTime.now(),
        status: 'completed',
        createdBy: user?.uid ?? 'unknown',
        courierId: courierId,
        courierName: courierName,
      );

      await _repository.createOrder(order);
      clearCart();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order completed successfully!')),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
      return false;
    } finally {
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>((ref) {
  return CartController(ref.watch(salesRepositoryProvider), ref);
});
