import 'dart:convert';

import 'package:digitales_register_app/digReg/profile.dart';
import 'package:digitales_register_app/theme/theme.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digitales_register_app/API/API.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int i = 0;
  bool notificationsEnabled;
  void changeNotification() {
    print(notificationsEnabled.toString());
    Session().post('https://fallmerayer.digitalesregister.it/v2/api/profile/updateNotificationSettings', notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);

    return FutureBuilder(
      future: Profile().getData(),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          if (i == 0) {
            notificationsEnabled =
            jsonDecode(snapshot.data)['notificationsEnabled'];
            i++;
          }
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
                          switchValue: _themeChanger.getBool()),
                      SettingsTile.switchTile(
                          title: 'Email-Benachrichtigungen',
                          onToggle: (value) {
                            setState(() {
                              notificationsEnabled = value;
                              changeNotification();
                            });
                          },
                          switchValue: notificationsEnabled)
                    ],
                  ),
                ],
              ),
            ),
          );
        }
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
    );
  }
}
