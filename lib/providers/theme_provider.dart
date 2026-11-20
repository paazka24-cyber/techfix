import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Notifier;

// Holds the current theme mode: system, light or dark
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
