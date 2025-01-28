import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4D8D),
          primary: const Color(0xFFFF4D8D),
          secondary: const Color(0xFFFF85A1),
          tertiary: const Color(0xFFFFB5C2),
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      );
}
