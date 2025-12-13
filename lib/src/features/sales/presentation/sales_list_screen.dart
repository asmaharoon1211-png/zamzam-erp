// lib/src/features/sales/presentation/sales_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/sales_repository.dart';
import '../../../services/pdf_service.dart';
import '../../../services/whatsapp_service.dart';

class SalesListScreen extends ConsumerWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sales History')),
      body: salesAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No sales yet'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  title: Text('Order #${order.id.substring(0, 5).toUpperCase()}'),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(order.date)),
                  trailing: Text(
                    '${order.totalAmount}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                  ),
                  children: [
                    ...order.items.map((item) => ListTile(
                      title: Text(item.productName),
                      subtitle: Text('${item.qty} x ${item.price}'),
                      trailing: Text('${item.total}'),
                      dense: true,
                    )),
                    ListTile(
                      title: const Text('Total', textAlign: TextAlign.right),
                      trailing: Text('${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.print),
                            label: const Text('Print'),
                            onPressed: () {
                               PdfService().printInvoice(order);
                            },
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.share, color: Colors.green),
                            label: const Text('WhatsApp', style: TextStyle(color: Colors.green)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                            ),
                            onPressed: () {
                               WhatsAppService().shareOrder(order);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/sales/pos'),
        icon: const Icon(Icons.point_of_sale),
        label: const Text('New Sale (POS)'),
      ),
    );
  }
}
