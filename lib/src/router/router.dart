// lib/src/router/router.dart
import 'package:flutter/material.dart' show BuildContext, Widget;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/inventory/presentation/inventory_screen.dart';
import '../features/inventory/presentation/add_product_screen.dart';
import '../features/sales/presentation/sales_list_screen.dart';
import '../features/sales/presentation/pos_screen.dart';
import '../features/purchase/presentation/purchase_list_screen.dart';
import '../features/purchase/presentation/add_purchase_screen.dart';
import '../features/couriers/presentation/courier_list_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isAuthenticated = authState.value != null;

      final isLogin = state.fullPath == '/auth/login';
      final isSignup = state.fullPath == '/auth/signup';

      if (isLoading || hasError) return null;

      if (!isAuthenticated) {
        // If not logged in and not on auth pages, redirect to login
        return (isLogin || isSignup) ? null : '/auth/login';
      } else {
        // If logged in and on auth pages, redirect to home
        if (isLogin || isSignup) return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (c, s) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (c, s) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: 'signup',
        builder: (c, s) => const SignupScreen(),
      ),
      GoRoute(
        path: '/inventory',
        name: 'inventory',
        builder: (c, s) => const InventoryScreen(),
        routes: [
          GoRoute(
            path: 'add-product',
            name: 'addProduct',
            builder: (c, s) => const AddProductScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/sales',
        name: 'sales',
        builder: (c, s) => const SalesListScreen(),
        routes: [
           GoRoute(
            path: 'pos',
            name: 'pos',
            builder: (c, s) => const POSScreen(),
          ),
        ]
      ),
      GoRoute(
        path: '/purchases',
        name: 'purchases',
        builder: (c, s) => const PurchaseListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'addPurchase',
            builder: (c, s) => const AddPurchaseScreen(),
          ),
        ]
      ),
      GoRoute(
        path: '/couriers',
        name: 'couriers',
        builder: (c, s) => const CourierListScreen(),
      ),
    ],
  );
});
