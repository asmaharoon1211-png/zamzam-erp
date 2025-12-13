// lib/src/features/couriers/controller/courier_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/courier_repository.dart';
import '../../../models/courier.dart';

class CourierController extends StateNotifier<bool> {
  final CourierRepository _repository;

  CourierController({required CourierRepository repository})
      : _repository = repository,
        super(false);

  Future<bool> saveCourier(Courier courier, BuildContext context) async {
    state = true;
    try {
      if (courier.id.isEmpty) {
        await _repository.createCourier(courier);
      } else {
        await _repository.updateCourier(courier.id, courier);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Courier saved')));
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

  Future<void> deleteCourier(String id, BuildContext context) async {
    try {
       await _repository.deleteCourier(id);
       if(context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Courier deleted')));
       }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

final courierControllerProvider = StateNotifierProvider<CourierController, bool>((ref) {
  return CourierController(repository: ref.watch(courierRepositoryProvider));
});
