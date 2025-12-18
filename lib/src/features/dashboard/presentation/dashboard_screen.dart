// lib/src/features/dashboard/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../../reports/presentation/dashboard_stats_widget.dart';
import '../../reports/data/reports_repository.dart';
import '../../settings/controller/locale_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(userRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
               ref.read(localeControllerProvider.notifier).toggleLocale();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      drawer: roleAsync.when(
        data: (role) {
          final isAdmin = role == 'admin';
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text('ZAMZAM ERP', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () => context.pop(),
                ),
                if (isAdmin)
                  ListTile(
                    leading: const Icon(Icons.inventory),
                    title: const Text('Inventory'),
                    onTap: () {
                      context.pop();
                      context.push('/inventory');
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Sales / POS'),
                  onTap: () {
                    context.pop();
                    context.push('/sales');
                  },
                ),
                if (isAdmin)
                  ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text('Purchases'),
                    onTap: () {
                      context.pop();
                      context.push('/purchases');
                    },
                  ),
                if (isAdmin)
                  ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: const Text('Couriers'),
                    onTap: () {
                      context.pop();
                      context.push('/couriers');
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Drawer(child: Center(child: CircularProgressIndicator())),
        error: (e, s) => Drawer(child: Center(child: Text('Error: $e'))),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(dashboardStatsProvider);
        },
        child: roleAsync.when(
          data: (role) {
             if (role == 'admin') {
               return const DashboardStatsWidget();
             } else {
               return const Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.lock, size: 60, color: Colors.grey),
                     SizedBox(height: 20),
                     Text('Stats restricted to Admin'),
                   ],
                 ),
               );
             }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e,s) => const Center(child: Text('Error')),
        ),
      ),
    );
  }
}
