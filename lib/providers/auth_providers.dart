import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authServiceProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final firebaseUser = ref.watch(authStateProvider).value;
  if (firebaseUser == null) return null;
  return ref.watch(authRepositoryProvider).getUser(firebaseUser.uid);
});
