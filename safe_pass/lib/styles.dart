import 'package:flutter/material.dart';

class Styles {
  static const titleTextStyle_Safe = TextStyle(
    fontSize: 40,
    color: Color(0xff087F8C),
    fontWeight: FontWeight.bold,
  );

  static const titleTextStyle_Pass = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
  );

  static const subtitleTextStyle_Safe = TextStyle(
    fontSize: 15,
    color: Color(0xff087F8C),
    fontWeight: FontWeight.bold,
  );

  static const subtitleTextStyle_Pass = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const subtitleText =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w300);

  static const loginButtonStyle = ButtonStyle(
    backgroundColor: MaterialStatePropertyAll(Color(0xff087F8C)),
  );
}
