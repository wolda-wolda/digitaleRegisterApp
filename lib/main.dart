/*digitaleRegister App Copyright (C) 2021 Martin Gamper, Kilian Kier, Marcel Walder
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import 'package:digitales_register_app/digReg/login_page.dart';
import 'package:digitales_register_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(

      create: (_) => ThemeChanger(ThemeMode.dark, Color(0xFF4285F4)),

      child: new MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      home: LoginPage(),
      themeMode: _theme.getMode(),
      theme: ThemeData.light().copyWith(primaryColor: _theme.getColor()),
      darkTheme: ThemeData.dark().copyWith(primaryColor: _theme.getColor()),
    );
  }
}
