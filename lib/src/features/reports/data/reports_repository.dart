// lib/src/features/reports/data/reports_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardStats {
  final int totalProducts;
  final int lowStockProducts;
  final double totalInventoryValue;
  final int todayOrders;
  final double todaySales;

  DashboardStats({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalInventoryValue,
    required this.todayOrders,
    required this.todaySales,
  });
}

class ReportsRepository {
  final FirebaseFirestore _firestore;

  ReportsRepository(this._firestore);

  Future<DashboardStats> getDashboardStats() async {
    // 1. Product Stats
    final productsSnapshot = await _firestore.collection('products').get();
    int totalProducts = productsSnapshot.docs.length;
    int lowStockProducts = 0;
    double totalInventoryValue = 0;

    for (var doc in productsSnapshot.docs) {
      final data = doc.data();
      final currentStock = (data['currentStock'] ?? 0) as int;
      final minStock = (data['minStock'] ?? 0) as int;
      final purchasePrice = (data['purchasePrice'] ?? 0) as num;

      if (currentStock <= minStock) {
        lowStockProducts++;
      }
      totalInventoryValue += (currentStock * purchasePrice);
    }

    // 2. Today's Sales
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final ordersSnapshot = await _firestore.collection('sales')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();
    
    int todayOrders = ordersSnapshot.docs.length;
    double todaySales = 0;
    
    for (var doc in ordersSnapshot.docs) {
      final data = doc.data();
      todaySales += (data['totalAmount'] ?? 0) as num;
    }

    return DashboardStats(
      totalProducts: totalProducts,
      lowStockProducts: lowStockProducts,
      totalInventoryValue: totalInventoryValue,
      todayOrders: todayOrders,
      todaySales: todaySales,
    );
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(FirebaseFirestore.instance);
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  return ref.watch(reportsRepositoryProvider).getDashboardStats();
});
