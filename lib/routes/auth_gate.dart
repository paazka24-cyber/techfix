import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/notification_providers.dart';
import '../screens/admin/admin_home.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/customer/customer_home.dart';
import '../screens/technician/technician_home.dart';
import '../widgets/splash_screen.dart';

// DEVELOPMENT ONLY: set to false to skip email verification while testing
// with fake emails. Keep it true for submission.
const bool requireEmailVerification = true;

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const SplashScreen(),
      error: (e, _) => _Message('Error: $e'),
      data: (firebaseUser) {
        if (firebaseUser == null) return const LoginScreen();
        if (requireEmailVerification && !firebaseUser.emailVerified) {
          return const VerifyEmailScreen();
        }

        ref.read(messagingServiceProvider).init(firebaseUser.uid);

        final appUser = ref.watch(appUserProvider);
        return appUser.when(
          loading: () => const SplashScreen(),
          error: (e, _) => _Message('Error: $e'),
          data: (user) {
            if (user == null) return const _Message('Profile not found');
            switch (user.role) {
              case 'customer':
                return const CustomerHome();
              case 'technician':
                return const TechnicianHome();
              case 'admin':
                return const AdminHome();
              default:
                return const _Message('Unknown role');
            }
          },
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  const _Message(this.text);

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(text)));
}
