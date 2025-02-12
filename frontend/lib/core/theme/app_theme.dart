import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getTheme(bool isDarkMode) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ).copyWith(
        surface: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        indicatorColor: Colors.blue.withOpacity(0.3),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        selectedColor: Colors.blue,
      ),
    );
  }
}
