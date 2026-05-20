import 'package:flutter/material.dart';

// OKLCH values from DESIGN.md converted to sRGB via standard formulas.
// Conversion notes: OKLCH(L C H) → OKLab → linear sRGB → gamma-corrected sRGB.
// Hand-computed to the nearest hex as documented in DESIGN.md approximate hex column.
abstract final class AppColors {
  // ── Light Mode ────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFB07D1A); // oklch(55% 0.15 68)
  static const Color primaryDim = Color(0xFFF5EDD8); // oklch(92% 0.05 72)
  static const Color surface = Color(0xFFFAF8F4); // oklch(97% 0.008 72)
  static const Color surfaceRaised = Color(0xFFFEFCF9); // oklch(99% 0.005 72)
  static const Color surfaceRecessed = Color(0xFFEDE9DF); // oklch(93% 0.012 72)
  static const Color textPrimary = Color(0xFF2A2318); // oklch(18% 0.01 68)
  static const Color textMuted = Color(0xFF7A6E5E); // oklch(48% 0.012 70)
  static const Color border = Color(0xFFD9D3C7); // oklch(86% 0.01 72)
  static const Color success = Color(0xFF2D7A4F); // oklch(52% 0.13 148)
  static const Color successDim = Color(0xFFE4F5EC); // oklch(94% 0.04 148)
  static const Color danger = Color(0xFFC04020); // oklch(52% 0.16 25)
  static const Color dangerDim = Color(0xFFF5E8E4); // oklch(94% 0.04 25)
  static const Color overlay = Color(0x7A2A2318); // oklch(18% 0.01 68 / 0.48)

  // ── Dark Mode ─────────────────────────────────────────────────────────────
  static const Color primaryDark = Color(0xFFD4A843); // oklch(72% 0.13 68)
  static const Color primaryDimDark = Color(0xFF3D2E0A); // oklch(24% 0.06 68)
  static const Color surfaceDark = Color(0xFF211C14); // oklch(14% 0.01 68)
  static const Color surfaceRaisedDark = Color(0xFF2D2720); // oklch(19% 0.01 68)
  static const Color surfaceRecessedDark = Color(0xFF181410); // oklch(11% 0.01 68)
  static const Color textPrimaryDark = Color(0xFFEEEAE1); // oklch(93% 0.008 72)
  static const Color textMutedDark = Color(0xFF9C9385); // oklch(62% 0.01 70)
  static const Color borderDark = Color(0xFF3C342A); // oklch(28% 0.012 68)
  static const Color successDark = Color(0xFF5AB87A); // oklch(65% 0.12 148)
  static const Color successDimDark = Color(0xFF0E2B1A); // oklch(20% 0.06 148)
  static const Color dangerDark = Color(0xFFE06040); // oklch(65% 0.14 25)
  static const Color dangerDimDark = Color(0xFF2B140E); // oklch(20% 0.06 25)
}
