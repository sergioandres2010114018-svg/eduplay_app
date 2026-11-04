import 'package:flutter/material.dart';

class C {
  static const navy = Color(0xFF0D1B5E);
  static const blue = Color(0xFF1E88E5);
  static const green = Color(0xFF6BBF3A);
  static const yellow = Color(0xFFFFB400);
  static const red = Color(0xFFE53935);
  static const bg = Color(0xFFF4F7FC);
}

const creditText =
    'App móvil creada por: Ana Lia Tovar, IE Pijiño y proyecto SenaTic';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
      seedColor: C.blue, primary: C.navy, secondary: C.green, tertiary: C.yellow);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
    appBarTheme: const AppBarTheme(
        backgroundColor: C.navy, foregroundColor: Colors.white, centerTitle: true),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
          backgroundColor: C.green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

Color hexColor(String h) => Color(int.parse('FF${h.replaceAll('#', '')}', radix: 16));

IconData areaIcon(String n) {
  switch (n) {
    case 'calculate':
      return Icons.calculate;
    case 'bolt':
      return Icons.bolt;
    case 'menu_book':
      return Icons.menu_book;
    default:
      return Icons.public;
  }
}
