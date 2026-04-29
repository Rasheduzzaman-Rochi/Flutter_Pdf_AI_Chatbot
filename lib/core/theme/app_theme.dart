import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.indigo,
    scaffoldBackgroundColor: const Color(0xfff7f8fb),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Color(0xfff7f8fb),
      elevation: 0,
    ),
  );
}