import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;
  ThemeChanger(this._themeData);
  bool getBool() {
    if (_themeData == ThemeData.dark()) {
      return true;
    }
    else {
      return false;
    }
  }
  void setBool(bool theme) {
    if (theme == true) {
      _themeData = ThemeData.dark();
    }
    else {
      _themeData = ThemeData.light();
    }
    notifyListeners();
  }
  getTheme() => _themeData;
}