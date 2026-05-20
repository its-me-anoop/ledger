import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Fraunces: display/amounts (variable opsz axis set via fontVariations).
// Be Vietnam Pro: body, labels, all prose.
// Type scale from DESIGN.md: 11/14/16/20/25/31/39 px, ratio 1.25.
abstract final class AppTypography {
  // ── Fraunces (display) ────────────────────────────────────────────────────
  static TextStyle fraunces({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double opsz = 36,
  }) {
    // opsz axis sets the optical-size variant of Fraunces (9–144 range).
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: _heightForSize(size),
    );
  }

  // ── Be Vietnam Pro (body) ─────────────────────────────────────────────────
  static TextStyle body({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.beVietnamPro(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: _heightForSize(size),
      letterSpacing: size <= 12 ? 0.08 * size : 0.01 * size,
    );
  }

  // ── Named scale tokens ────────────────────────────────────────────────────
  static TextStyle xs({Color? color}) =>
      body(size: 11, color: color); // timestamps, meta labels
  static TextStyle sm({Color? color}) =>
      body(size: 14, color: color); // helper text, captions
  static TextStyle base({Color? color, FontWeight weight = FontWeight.w400}) =>
      body(size: 16, weight: weight, color: color); // body
  static TextStyle lg({Color? color, FontWeight weight = FontWeight.w500}) =>
      body(size: 20, weight: weight, color: color); // section labels
  static TextStyle xl({Color? color}) =>
      fraunces(size: 25, weight: FontWeight.w600, color: color, opsz: 36); // screen title
  static TextStyle xxl({Color? color}) =>
      fraunces(size: 31, color: color, opsz: 36); // balance total
  static TextStyle xxxl({Color? color}) =>
      fraunces(size: 39, color: color, opsz: 72); // hero amount

  static double _heightForSize(double size) {
    if (size >= 36) return 1.2;
    if (size >= 28) return 1.3;
    if (size >= 22) return 1.4;
    if (size >= 16) return 1.6;
    return 1.5;
  }

  static TextTheme get textTheme => TextTheme(
    displayLarge: fraunces(size: 39, opsz: 72),
    displayMedium: fraunces(size: 31, opsz: 36),
    displaySmall: fraunces(size: 25, weight: FontWeight.w600, opsz: 36),
    headlineMedium: body(size: 20, weight: FontWeight.w500),
    titleMedium: body(size: 16, weight: FontWeight.w500),
    bodyLarge: body(size: 16),
    bodyMedium: body(size: 14),
    bodySmall: body(size: 11),
    labelSmall: body(size: 11),
  );
}
