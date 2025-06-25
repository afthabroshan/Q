// theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF00585A); // Green
  static const cream = Color(0xFFF6F1EB); // Red
  static const textdark = Color(0xFF7B817F);
  static const textwhite = Colors.white;
  static const textblack = Colors.black;
  static const red = Colors.red;
  static const lightgreen = Colors.green;
}

class AppTextStyles {
  static const smallheading = TextStyle(
    fontSize: 15,
    // fontWeight: FontWeight.bold,
    color: AppColors.textwhite,
    fontFamily: 'Amiri',
  );

  static const bigheading = TextStyle(
    fontSize: 50,
    // fontWeight: FontWeight.bold,
    color: AppColors.textwhite,
    fontFamily: 'Amiri',
  );
  static const contentblack = TextStyle(
    fontSize: 25,
    // fontWeight: FontWeight.bold,
    color: AppColors.textblack,
    fontFamily: 'Amiri',
  );
  static const contentwhite = TextStyle(
    fontSize: 25,
    // fontWeight: FontWeight.bold,
    color: AppColors.textwhite,
    fontFamily: 'Amiri',
  );
  static const midheading = TextStyle(
    fontSize: 30,
    // fontWeight: FontWeight.bold,
    color: AppColors.textwhite,
    fontFamily: 'Amiri',
  );
}
