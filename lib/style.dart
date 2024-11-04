import 'package:flutter/material.dart';

var _var1; // _붙이면 다른 파일에서 가져다 쓰는거 방지 됨

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
