import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Colores {
  static const navy = Color(0xFF000C56);
  static const azul = Color(0xFF0681FB);
  static const menta = Color(0xFFA1EAE3);
  static const fondo = Color(0xFFF5F8FE);
  static const gris = Color(0xFF5A6070);
}

ThemeData temaSaliHub() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colores.azul,
      primary: Colores.azul,
      secondary: Colores.menta,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colores.fondo,
  );
  final cuerpo = GoogleFonts.interTextTheme(base.textTheme);
  return base.copyWith(
    textTheme: cuerpo.copyWith(
      headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colores.navy),
      titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colores.navy),
      titleMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colores.navy),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colores.fondo,
      foregroundColor: Colores.navy,
      elevation: 0,
      titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colores.navy),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colores.azul,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
  );
}
