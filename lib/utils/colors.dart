import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);

  // Secondary color
  static const Color secondaryColor = Color(0xFFB0BEC5); // Light Grey
  // Black and white color scheme
  static const Color bgColor = Colors.black;
  static const Color fgColor = Colors.white;
  static const Color accentColor = Colors.white;
  // Success and error colors
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color errorColor = Color(0xFFF44336); // Red
  // Borders (dark-first scheme with light variants for white backgrounds)
  static const Color borderColor = Color(
    0xFF2C2C2C,
  ); // subtle border on black surfaces
  static const Color borderLight = Color(
    0xFF424242,
  ); // slightly lighter divider
  static const Color borderOnWhite = Color(
    0xFFE0E0E0,
  ); // subtle border for white backgrounds

  // Icon colors
  static const Color iconColor = Colors.white; // primary icon color on dark bg
  static const Color iconMuted = Color(
    0x80FFFFFF,
  ); // semi-transparent white (muted)
  static const Color iconDisabled = Color(
    0x66FFFFFF,
  ); // more transparent for disabled state
  static const Color iconOnWhite = Color(
    0xFF212121,
  ); // dark icon for white surfaces
}
