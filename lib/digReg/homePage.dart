import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/digReg/absences.dart';
import 'package:digitales_register_app/digReg/calendar.dart';
import 'package:digitales_register_app/digReg/dashboard.dart';
import 'package:digitales_register_app/digReg/login_page.dart';
import 'package:digitales_register_app/digReg/messages.dart';
import 'package:digitales_register_app/digReg/profile.dart';
import 'package:digitales_register_app/digReg/settings.dart';
import 'package:digitales_register_app/digReg/subjects.dart';
import 'package:digitales_register_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';

import 'PopUpMenu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String profile;
  int _selectedIndex = 0;

  @override
  void initState() {
    setState(() {
      super.initState();
      initializeDateFormatting('de_DE');
    });
  }

  List<String> options = <String>[
    'Merkheft',
    'Absenzen',
    'Kalender',
    'Noten',
    'Mitteilungen',
    'Profil'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _options(BuildContext context, int select) {
    return <Widget>[
      DrawDashboard(update: _onItemTapped),
      DrawAbsences(),
      Calendar().build(context),
      DrawSubjects(),
      DrawMessages(),
      DrawProfile()
    ][select];
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Digitales Register'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                if (choice == Constants.Setting) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.settings_applications,
                          color: Colors.grey,
                        ),
                        Text(choice),
                      ],
                    ),
                  );
                } else if (choice == Constants.Logout) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.exit_to_app,
                          color: Colors.grey,
                        ),
                        Text(choice),
                      ],
                    ),
                  );
                }
              }).toList();
            },
          ),
        ],
      ),
      body: Center(child: _options(context, _selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        //fixedColor: Color(0xFF4285F4),
        fixedColor: _themeChanger.getColor(),
        unselectedItemColor: Colors.grey[800],
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.book),
            label: 'Merkheft',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.thermometer),
            label: 'Absenzen',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.calendar),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.graduation_cap),
            label: 'Noten',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.inbox),
            label: 'Mitteilungen',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.user_tie),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          _onItemTapped(index);
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Future<void> logout() async {
    await Session().get(Data.currentlink + '/v2/logout');
  }

  void choiceAction(String choice) {
    if (choice == Constants.Setting) {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => Settings(),
              transitionDuration: Duration(milliseconds: 100)));
    } else if (choice == Constants.Logout) {
      logout();
      Data().initFirstaccess();
      Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) {
                return LoginPage();
              },
              transitionDuration: Duration(milliseconds: 100)),
          (route) => false);
    }
  }
}
