// lib/src/features/auth/controller/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(false); // false = not loading

  Future<bool> signIn(String email, String password, BuildContext context) async {
    state = true;
    try {
      await _authRepository.signIn(email, password);
      // Navigation is handled by Router stream
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return false;
    } finally {
      if (mounted) state = false;
    }
  }

  Future<bool> signUp(String email, String password, BuildContext context) async {
    state = true;
    try {
      await _authRepository.signUp(email, password);
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return false;
    } finally {
      if (mounted) state = false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authRepository: ref.watch(authRepositoryProvider),
  );
});
