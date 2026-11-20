import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Light mode' : 'Dark mode',
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () => ref.read(themeModeProvider.notifier).state =
          isDark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
