import 'package:flutter/material.dart';
import 'colors.dart';

class AppStyles {
  // Text styles
  static const TextStyle headingStyle = TextStyle(
    color: AppColors.primaryBlack,
    fontSize: 24.0, // Fixed size for headings
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    color: AppColors.primaryBlack,
    fontSize: 16.0,
  );

  static const TextStyle errorTextStyle = TextStyle(
    color: AppColors.errorColor,
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle successTextStyle = TextStyle(
    color: AppColors.successColor,
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle secondaryTextStyle = TextStyle(
    color: AppColors.secondaryColor,
    fontSize: 16.0,
  );
}
