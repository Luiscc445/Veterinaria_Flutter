import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema de la aplicación RamboPet
class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF2196F3); // Azul
  static const Color secondaryColor = Color(0xFFFF9800); // Naranja
  static const Color accentColor = Color(0xFF4CAF50); // Verde
  static const Color errorColor = Color(0xFFE53935); // Rojo
  static const Color warningColor = Color(0xFFFFC107); // Amarillo
  static const Color successColor = Color(0xFF4CAF50); // Verde
  static const Color infoColor = Color(0xFF2196F3); // Azul

  // Colores de fondo
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Colores de texto
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);

  /// Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        background: backgroundLight,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimaryLight,
        onSurface: textPrimaryLight,
        onError: Colors.white,
      ),

      // Tipografía
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryLight,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          color: textPrimaryLight,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          color: textPrimaryLight,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          color: textSecondaryLight,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Tarjetas
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceLight,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.roboto(color: textSecondaryLight),
        hintStyle: GoogleFonts.roboto(color: textSecondaryLight),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryLight,
        selectedLabelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.roboto(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: backgroundLight,
        selectedColor: primaryColor.withOpacity(0.2),
        labelStyle: GoogleFonts.roboto(color: textPrimaryLight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 1,
      ),

      // IconTheme
      iconTheme: const IconThemeData(
        color: textPrimaryLight,
        size: 24,
      ),
    );
  }

  /// Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        background: backgroundDark,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimaryDark,
        onSurface: textPrimaryDark,
        onError: Colors.white,
      ),

      // Tipografía (similar al tema claro pero con colores oscuros)
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryDark,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          color: textPrimaryDark,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          color: textPrimaryDark,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          color: textSecondaryDark,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: textPrimaryDark),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Tarjetas
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceDark,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.roboto(color: textSecondaryDark),
        hintStyle: GoogleFonts.roboto(color: textSecondaryDark),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryDark,
        selectedLabelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.roboto(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: backgroundDark,
        selectedColor: primaryColor.withOpacity(0.3),
        labelStyle: GoogleFonts.roboto(color: textPrimaryDark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
        space: 1,
      ),

      // IconTheme
      iconTheme: const IconThemeData(
        color: textPrimaryDark,
        size: 24,
      ),
    );
  }
}
