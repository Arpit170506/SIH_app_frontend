import 'package:flutter/material.dart';
import 'screen/login_screen.dart';

// ======= MAIN =======
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'AMU Tracker',
    theme: ThemeData(
      primarySwatch: MaterialColor(0xFF0F7F19, {
        50: Color(0xFFE3F2FD),
        100: Color(0xFFBBDEFB),
        200: Color(0xFF90CAF9),
        300: Color(0xFF64B5F6),
        400: Color(0xFF42A5F5),
        500: Color(0xFF0F7F19),
        600: Color(0xFF1E88E5),
        700: Color(0xFF1976D2),
        800: Color(0xFF1565C0),
        900: Color(0xFF0D47A1),
      }),
      fontFamily: 'Roboto',
    ),
    home: LoginScreen(),
  ));
}