import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:digitales_register_app/theme/theme.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  static int i = 0;
  static bool notificationsEnabled;
  Future<bool> changeNotification() async{
    if((await Session().post(Data.currentlink +'/v2/api/profile/updateNotificationSettings', {'notificationsEnabled': notificationsEnabled}))=='e'){
      return false;
    }
    else{
      return true;
    }

  }

  void changeColor(Color color, ThemeChanger _themeChanger) {
    setState(() {
      _themeChanger.setColor(color);
    });
  }

  Widget notifications(bool notificationsEnabled) {
    if (notificationsEnabled == true)
      return Icon(Icons.notifications_active);
    else
      return Icon(Icons.notifications);
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
          await Data().StoreTheme(_themeChanger.getColor(),_themeChanger.getBool());
          return;
    });
  }
  final snackbar =  GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
        String data=Data.profile;
        if (data != null) {
          if (!data.contains('window.location')) {
            if (i == 0) {
              notificationsEnabled =
              jsonDecode(data)['notificationsEnabled'];
              i++;
            }
            return Scaffold(
              key: snackbar,
              appBar: AppBar(title: Text('Settings')),
              body: Center(
                child: SettingsList(
                  sections: [
                    SettingsSection(
                      tiles: [
                        SettingsTile(
                          leading: Icon(Icons.color_lens),
                          title: 'Theme ändern',
                          onPressed: (_) => showColorPicker(context, _themeChanger),
                        ),
                        SettingsTile.switchTile(
                            leading: darkMode(_themeChanger.getBool()),
                            title: 'Dark Mode',
                            onToggle: (value) {
                              _themeChanger.setBool(value);
                            },
                            switchValue: _themeChanger.getBool()),
                        SettingsTile.switchTile(
                            leading: notifications(notificationsEnabled),
                            title: 'Email-Benachrichtigungen',
                            onToggle: (value) async{
                              if(await changeNotification()==true){
                                notificationsEnabled = !notificationsEnabled;
                              }
                              else{
                                snackbar.currentState.showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),content: Text('Keine Netzwerkverbindung')));
                              }
                                setState((){});
                            },
                            switchValue: notificationsEnabled)
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
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
                          await Data().StoreTheme(_themeChanger.getColor(),_themeChanger.getBool());
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
