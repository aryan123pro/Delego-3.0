import 'package:flutter/material.dart';
class Style {
  static const baseTextStyle = TextStyle(
    fontFamily: 'Avenir',
  );
  static final smallTextStyle = commonTextStyle.copyWith(
    fontSize: 9.0,
  );
  static final commonTextStyle = baseTextStyle.copyWith(
      color: const Color(0xffb6b2df),
      fontSize: 16.0,
      fontWeight: FontWeight.w400
  );
  static final regularTextStyle = baseTextStyle.copyWith(
      color: const Color(0xffb6b2df),
      fontSize: 16.0,
      fontWeight: FontWeight.w400
  );
  static final regularTextStyle2 = baseTextStyle.copyWith(
      color: const Color(0xffb6b2df),
      fontSize: 16.0,
      fontWeight: FontWeight.w500
  );
  static final titleTextStyle = baseTextStyle.copyWith(
      color: Colors.white,
      fontSize: 18.0,
      fontWeight: FontWeight.w600
  );
  static final headerTextStyle = baseTextStyle.copyWith(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.w400
  );
  static final headerTextStyle2 = baseTextStyle.copyWith(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.w600
  );
}