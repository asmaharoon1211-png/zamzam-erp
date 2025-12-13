// lib/src/features/inventory/presentation/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/inventory_repository.dart';
import '../../../models/product.dart';
import '../controller/inventory_controller.dart';
import '../../auth/data/auth_repository.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final roleAsync = ref.watch(userRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          
          // Product List
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = products.where((p) {
                  return p.name.toLowerCase().contains(_searchQuery) ||
                         p.sku.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return roleAsync.when(
                  data: (role) {
                    final isAdmin = role == 'admin';
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: product.imageUrl != null
                                ? CircleAvatar(backgroundImage: NetworkImage(product.imageUrl!))
                                : const CircleAvatar(child: Icon(Icons.inventory_2)),
                            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('SKU: ${product.sku} | Stock: ${product.currentStock} ${product.unit}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Sale: ${product.salePrice}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                if (isAdmin) Text('Pur: ${product.purchasePrice}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            onLongPress: isAdmin ? () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Product?'),
                                  content: Text('Are you sure you want to delete ${product.name}?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        ref.read(inventoryControllerProvider.notifier).deleteProduct(product.id, context);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            } : null,
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                );
              },
              error: (err, stack) => Center(child: Text('Error: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
      floatingActionButton: roleAsync.when(
        data: (role) => role == 'admin' ? FloatingActionButton(
          onPressed: () => context.push('/inventory/add-product'),
          child: const Icon(Icons.add),
        ) : null,
        loading: () => null,
        error: (e, s) => null,
      ),
    );
  }
}
