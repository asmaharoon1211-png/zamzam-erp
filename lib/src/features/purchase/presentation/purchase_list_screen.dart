// lib/src/features/purchase/presentation/purchase_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/purchase_repository.dart';

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchasesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase History')),
      body: purchasesAsync.when(
        data: (purchases) {
          if (purchases.isEmpty) return const Center(child: Text('No purchases recorded'));
          
          return ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  title: Text(purchase.supplierName.isEmpty ? 'Unknown Supplier' : purchase.supplierName),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(purchase.date)),
                  trailing: Text('${purchase.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  children: [
                    ...purchase.items.map((item) => ListTile(
                      title: Text(item.productName),
                      subtitle: Text('${item.qty} x ${item.price}'),
                      trailing: Text('${item.total}'),
                      dense: true,
                    )),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/purchases/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
