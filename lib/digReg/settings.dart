import 'package:digitales_register_app/theme/theme.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
                SettingsTile.switchTile(
                    title: 'Dark Mode',
                    onToggle: (value) {
                      _themeChanger.setBool(value);
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
