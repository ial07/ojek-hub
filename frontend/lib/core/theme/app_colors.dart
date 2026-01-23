import 'package:flutter/material.dart';

class AppColors {
  // Primary Actions
  static const Color primaryBlack = Color(0xFF111827); // Almost purely black
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color primaryGreen = Color(0xFF16A34A); // Standard Green 600

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF9FAFB); // Very light grey
  static const Color inputBackground = Color(0xFFF3F4F6); // Creating job inputs

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textPlaceholder = Color(0xFF9CA3AF);

  // Accents (Pastels)
  static const Color pastelGreen = Color(0xFFDCFCE7); // Success/Open background
  static const Color pastelGreenText = Color(0xFF166534); // Success/Open text

  static const Color pastelRed = Color(0xFFFEE2E2); // Error/Closed background
  static const Color pastelRedText = Color(0xFF991B1B); // Error/Closed text

  static const Color pastelOrange = Color(0xFFFEF3C7); // Pending background
  static const Color pastelOrangeText = Color(0xFF92400E); // Pending text

  // Borders
  static const Color borderLight = Color(0xFFE5E7EB);
}

class AppDimensions {
  static const double radiusCard = 24.0;
  static const double radiusButton = 12.0;
  static const double radiusInput = 16.0;

  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
}
