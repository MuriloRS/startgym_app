import 'package:flutter/material.dart';

class ThemeDataStartgym {
  static ThemeData buildThemeData() {
    return ThemeData(
      fontFamily: 'Oswald',
      textTheme: TextTheme(
        subtitle: TextStyle(
            fontWeight: FontWeight.normal, color: Colors.black, fontSize: 22),
        title: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 26.0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[700], width: 1.0),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[700], width: 1.0),
        ),
      ),
      primaryColor: Colors.black,
      accentColor: Color.fromRGBO(227, 0, 0, 1),
      buttonColor: Color.fromRGBO(25, 149, 25, 1),
      colorScheme: ColorScheme.dark(primary: Colors.blue[700]),
      backgroundColor: Colors.white,
    );
  }
}
