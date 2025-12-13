// lib/src/features/sales/presentation/pos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inventory/data/inventory_repository.dart';
import '../controller/cart_controller.dart';
import '../../../models/product.dart';
import '../../../models/courier.dart';
import '../../couriers/data/courier_repository.dart';

class POSScreen extends ConsumerWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS Terminal')),
      body: Row(
        children: [
          Expanded(flex: 2, child: _ProductSelectionView()),
          const VerticalDivider(width: 1),
          Expanded(flex: 1, child: _CartView()),
        ],
      ),
    );
  }
}

class _ProductSelectionView extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ProductSelectionView> createState() => _ProductSelectionViewState();
}

class _ProductSelectionViewState extends ConsumerState<_ProductSelectionView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(hintText: 'Search Product...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
          ),
        ),
        Expanded(
          child: productsAsync.when(
            data: (products) {
              final filtered = products.where((p) => p.name.toLowerCase().contains(_searchQuery) || p.sku.toLowerCase().contains(_searchQuery)).toList();
              if (filtered.isEmpty) return const Center(child: Text('No products found'));

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  final isOutOfStock = product.currentStock <= 0;
                  return Card(
                    color: isOutOfStock ? Colors.grey.shade200 : null,
                    child: InkWell(
                      onTap: isOutOfStock ? null : () => ref.read(cartControllerProvider.notifier).addToCart(product),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: product.imageUrl != null ? Image.network(product.imageUrl!, fit: BoxFit.cover) : const Icon(Icons.shopping_bag, size: 40)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${product.salePrice}'),
                                isOutOfStock ? const Text('Out of Stock', style: TextStyle(color: Colors.red, fontSize: 10)) : Text('Stock: ${product.currentStock}', style: const TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            error: (e, s) => Center(child: Text('Error: $e')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

class _CartView extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<_CartView> {
  Courier? _selectedCourier;

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final items = cartState.items;
    final couriersAsync = ref.watch(couriersStreamProvider);

    return Column(
      children: [
        Container(padding: const EdgeInsets.all(16), color: Colors.blue.shade50, width: double.infinity, child: const Text('Current Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Cart is empty'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.productName),
                      subtitle: Text('${item.qty} x ${item.price}'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('${item.total}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.orange), onPressed: () => ref.read(cartControllerProvider.notifier).decrementQty(item)),
                      ]),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))]),
          child: Column(
            children: [
             // Courier Selector
              couriersAsync.when(
                data: (couriers) {
                  return DropdownButtonFormField<Courier>(
                    decoration: const InputDecoration(labelText: 'Select Courier (Optional)', border: OutlineInputBorder()),
                    value: _selectedCourier,
                    items: [
                      const DropdownMenuItem<Courier>(value: null, child: Text('No Courier (Walk-in)')),
                      ...couriers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))),
                    ],
                    onChanged: (val) => setState(() => _selectedCourier = val),
                  );
                },
                loading: () => const LinearProgressIndicator(), // Small indicator
                error: (e,s) => const SizedBox(), // Hide on error
              ),
              const SizedBox(height: 10),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('${cartState.total}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: items.isEmpty || cartState.isLoading
                      ? null
                      : () => ref.read(cartControllerProvider.notifier).checkout(
                        context, 
                        courierId: _selectedCourier?.id, 
                        courierName: _selectedCourier?.name
                      ),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: cartState.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('CHECKOUT'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
