// lib/src/features/reports/presentation/dashboard_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/reports_repository.dart';

class DashboardStatsWidget extends ConsumerWidget {
  const DashboardStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) {
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildStatCard('Total Products', '${stats.totalProducts}', Colors.blue),
              _buildStatCard('Low Stock', '${stats.lowStockProducts}', Colors.red),
              _buildStatCard('Inv. Value', '${stats.totalInventoryValue.toStringAsFixed(2)}', Colors.orange),
              _buildStatCard("Today's Orders", '${stats.todayOrders}', Colors.green),
              _buildStatCard("Today's Sales", '${stats.todaySales.toStringAsFixed(2)}', Colors.purple),
            ],
          ),
        );
      },
      error: (e, s) => Center(child: Text('Error loading stats: $e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.analytics, color: color),
        ),
        title: Text(title, style: TextStyle(color: Colors.grey[600])),
        trailing: Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color),
        ),
      ),
    );
  }
}
