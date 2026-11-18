import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(authRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => repo.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'We sent a verification link to your email.\n'
              'Open it, then tap the button below.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => repo.reloadUser(),
                child: const Text("I've verified my email"),
              ),
            ),
            TextButton(
              onPressed: () async {
                await repo.sendVerificationEmail();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email sent.')),
                );
              },
              child: const Text('Resend email'),
            ),
          ],
        ),
      ),
    );
  }
}
