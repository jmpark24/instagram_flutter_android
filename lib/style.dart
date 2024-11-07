import 'package:flutter/material.dart';

ThemeData theme = ThemeData(
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(backgroundColor: Colors.grey)),
  elevatedButtonTheme: ElevatedButtonThemeData(),
  appBarTheme: AppBarTheme(
    color: Colors.white,
    elevation: 1,
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 25),
    actionsIconTheme: IconThemeData(color: Colors.black),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedIconTheme: IconThemeData(color: Colors.black),
  ),
);
