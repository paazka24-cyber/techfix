import 'package:flutter/material.dart';

IconData categoryIcon(String name) {
  switch (name.toLowerCase()) {
    case 'phone':
      return Icons.smartphone;
    case 'laptop':
      return Icons.laptop;
    case 'tablet':
      return Icons.tablet_android;
    case 'desktop':
      return Icons.desktop_windows;
    case 'console':
      return Icons.sports_esports;
    default:
      return Icons.devices_other;
  }
}
