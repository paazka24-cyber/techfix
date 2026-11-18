import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// TODO: you write authRepositoryProvider
//   hint: it needs an AuthService, so use ref.watch(authServiceProvider)

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authServiceProvider));
});

// Is someone logged in? Emits a new value on every login/logout.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// The Firestore profile (with the role) of the logged-in user.
final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final firebaseUser = ref.watch(authStateProvider).value;
  if (firebaseUser == null) return null; // nobody logged in
  return ref.watch(authRepositoryProvider).getUser(firebaseUser.uid);
});
