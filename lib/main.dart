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
