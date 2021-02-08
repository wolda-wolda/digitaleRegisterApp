import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  ThemeMode _themeMode;
  Color _color;
  ThemeChanger(this._themeMode, this._color);

  bool getBool() {
    if (_themeMode == ThemeMode.dark) {
      return true;
    }
    else {
      return false;
    }
  }

  void setBool(bool theme) {
    if (theme == true) {
      _themeMode = ThemeMode.dark;
    }
    else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  getMode() => _themeMode;

  void setColor(Color color) {
    _color = color;
    notifyListeners();
  }

  getColor() => _color;

}
