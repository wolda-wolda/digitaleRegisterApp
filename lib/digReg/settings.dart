import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:digitales_register_app/theme/theme.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  void changeColor(Color color, ThemeChanger _themeChanger) {
    setState(() {
      _themeChanger.setColor(color);
    });
  }


  Widget darkMode(bool theme) {
    if (theme == true)
      return Icon(Icons.wb_incandescent);
    else
      return Icon(Icons.wb_incandescent_outlined);
  }

  void showColorPicker(BuildContext context, ThemeChanger _themeChanger) async{
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Wähle eine Farbe'),
            content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: _themeChanger.getColor(),
                  showLabel: true,
                  onColorChanged: (color)async{
                    changeColor(color, _themeChanger);
                  },
            ),
            ),
          );
        }).then((context) async{
          await Data().storeTheme(_themeChanger.getColor(),_themeChanger.getBool());
          return;
    });
  }
  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
        return Scaffold(
          appBar: AppBar(title: Text('Settings')),
          body: Center(
            child: SettingsList(
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile(
                      leading: Icon(Icons.color_lens),
                      title: 'Theme ändern',
                      onPressed: (_){
                        showColorPicker(context, _themeChanger);
                        },
                    ),
                    SettingsTile.switchTile(
                        leading: darkMode(_themeChanger.getBool()),
                        title: 'Dark Mode',
                        onToggle: (value) async{
                          _themeChanger.setBool(value);
                          await Data().storeTheme(_themeChanger.getColor(),_themeChanger.getBool());
                        },
                        switchValue: _themeChanger.getBool())
                  ],
                ),
              ],
            ),
          ),
        );
  }
}
