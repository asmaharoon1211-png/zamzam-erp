// lib/src/features/purchase/presentation/add_purchase_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../inventory/data/inventory_repository.dart';
import '../data/purchase_repository.dart';
import '../controller/purchase_controller.dart';
import '../../../models/purchase.dart';
import '../../../models/cart_item.dart';
import '../../../models/supplier.dart';
import '../../auth/data/auth_repository.dart';

class AddPurchaseScreen extends ConsumerStatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  ConsumerState<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends ConsumerState<AddPurchaseScreen> {
  Supplier? _selectedSupplier;
  final List<CartItem> _items = [];
  
  void _addItem(CartItem item) {
    setState(() {
      _items.add(item);
    });
  }

  double get _total => _items.fold(0, (sum, item) => sum + item.total);

  Future<void> _save() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a supplier')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one product')));
      return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    final purchase = Purchase(
      id: '',
      supplierId: _selectedSupplier!.id,
      supplierName: _selectedSupplier!.name,
      date: DateTime.now(),
      items: _items,
      totalAmount: _total,
      status: 'completed',
      createdBy: user?.uid ?? 'unknown',
    );

    final success = await ref.read(purchaseControllerProvider.notifier).createPurchase(purchase, context);
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final isLoading = ref.watch(purchaseControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Purchase (Stock In)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Supplier Dropdown
            suppliersAsync.when(
              data: (suppliers) {
                 return DropdownButtonFormField<Supplier>(
                  decoration: const InputDecoration(labelText: 'Supplier'),
                  value: _selectedSupplier,
                  items: suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: (val) => setState(() => _selectedSupplier = val),
                 );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e,s) => Text('Error: $e'),
            ),
            const SizedBox(height: 20),
            
            // Product Selection (Simple list for MVP)
            Expanded(
              child: productsAsync.when(
                data: (products) {
                   return ListView.separated(
                     itemCount: products.length,
                     separatorBuilder: (c, i) => const Divider(),
                     itemBuilder: (context, index) {
                       final product = products[index];
                       return ListTile(
                         title: Text(product.name),
                         subtitle: Text('Current Stock: ${product.currentStock}'),
                         trailing: IconButton(
                           icon: const Icon(Icons.add_shopping_cart),
                           onPressed: () {
                             // Show dialog to enter Qty and Cost
                             showDialog(
                               context: context,
                               builder: (ctx) {
                                 final qtyCtrl = TextEditingController(text: '1');
                                 final costCtrl = TextEditingController(text: '${product.purchasePrice}');
                                 return AlertDialog(
                                   title: Text('Add ${product.name}'),
                                   content: Column(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
                                       TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'Unit Cost'), keyboardType: TextInputType.number),
                                     ],
                                   ),
                                   actions: [
                                     TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                     TextButton(onPressed: () {
                                       final qty = int.tryParse(qtyCtrl.text) ?? 1;
                                       final cost = double.tryParse(costCtrl.text) ?? 0;
                                       _addItem(CartItem(
                                         productId: product.id,
                                         productName: product.name,
                                         price: cost,
                                         qty: qty,
                                       ));
                                       Navigator.pop(ctx);
                                     }, child: const Text('Add')),
                                   ],
                                 );
                               }
                             );
                           },
                         ),
                       );
                     },
                   );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e,s) => Text('Error: $e'),
              ),
            ),

            const Divider(thickness: 2),
            // Cart Summary
            Container(
              height: 150,
              color: Colors.grey.shade100,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (c, i) => ListTile(
                  title: Text(_items[i].productName),
                  subtitle: Text('${_items[i].qty} x ${_items[i].price}'),
                  trailing: Text('${_items[i].total}'),
                  dense: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: $_total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: isLoading ? null : _save,
                    child: isLoading ? const CircularProgressIndicator() : const Text('Confirm Purchase'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
