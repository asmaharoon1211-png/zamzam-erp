// lib/src/features/couriers/presentation/courier_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/courier_repository.dart';
import '../controller/courier_controller.dart';
import '../../../models/courier.dart';

class CourierListScreen extends ConsumerWidget {
  const CourierListScreen({super.key});

  void _showAddEditDialog(BuildContext context, WidgetRef ref, {Courier? courier}) {
    final nameCtrl = TextEditingController(text: courier?.name ?? '');
    final phoneCtrl = TextEditingController(text: courier?.phone ?? '');
    final feeCtrl = TextEditingController(text: courier?.fixedFee.toString() ?? '0'); // Basic fixed fee for now

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(courier == null ? 'Add Courier' : 'Edit Courier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. TCS)')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: feeCtrl, decoration: const InputDecoration(labelText: 'Fixed Fee'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newCourier = Courier(
                id: courier?.id ?? '', // Logic handles update vs create
                name: nameCtrl.text,
                phone: phoneCtrl.text,
                fixedFee: double.tryParse(feeCtrl.text) ?? 0,
                percentFee: 0, // Ignoring percentage for MVP
              );
              ref.read(courierControllerProvider.notifier).saveCourier(newCourier, context);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couriersAsync = ref.watch(couriersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Couriers')),
      body: couriersAsync.when(
        data: (couriers) {
          if (couriers.isEmpty) return const Center(child: Text('No couriers added'));
          
          return ListView.builder(
            itemCount: couriers.length,
            itemBuilder: (context, index) {
              final courier = couriers[index];
              return ListTile(
                title: Text(courier.name),
                subtitle: Text('Fee: ${courier.fixedFee} | Phone: ${courier.phone}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () => ref.read(courierControllerProvider.notifier).deleteCourier(courier.id, context),
                ),
                onTap: () => _showAddEditDialog(context, ref, courier: courier),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
