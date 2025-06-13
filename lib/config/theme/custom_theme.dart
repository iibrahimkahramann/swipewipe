import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData themeData(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      navigationBarTheme: navigationBarThemeData(),
      textTheme: textTheme(context),
    );
  }

  static const Color primaryColor = Colors.black;
  static const Color secondaryColor = Color.fromARGB(255, 28, 28, 29);
  static const Color accentColor = Colors.white;
  static const Color backgroundColor = Color.fromARGB(255, 21, 21, 21);
  static const Color boldColor = Colors.white;
  static const Color mediumColor = Colors.white;
  static const Color regularColor = Color.fromARGB(255, 167, 167, 167);
  static const Color verysmallcolor = Color.fromARGB(255, 31, 31, 31);

  static NavigationBarThemeData navigationBarThemeData() {
    return NavigationBarThemeData(
      backgroundColor: backgroundColor,
    );
  }

  static TextTheme textTheme(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return TextTheme(
      bodyLarge: TextStyle(
        fontSize: height * 0.0345,
        fontWeight: FontWeight.bold,
        color: boldColor,
        fontFamily: 'Poppins',
      ),
      bodyMedium: TextStyle(
        fontSize: height * 0.0275,
        fontWeight: FontWeight.bold,
        color: boldColor,
        fontFamily: 'Poppins',
      ),
      bodySmall: TextStyle(
        fontSize: height * 0.019,
        fontWeight: FontWeight.bold,
        color: boldColor,
        fontFamily: 'Poppins',
      ),
    );
  }

  static BoxDecoration customBoxDecoration({
    Color color = accentColor,
    double borderRadius = 8.0,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}
