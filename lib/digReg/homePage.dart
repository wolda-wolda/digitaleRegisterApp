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
import 'package:provider/provider.dart';

import 'PopUpMenu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String profile;

  @override
  void initState() {
    setState(() {
      super.initState();
      _tabController = TabController(length: options.length, vsync: this);
      initializeDateFormatting('de_DE');
    });
  }

  int _selectedIndex = 0;
  List<String> options = <String>[
    'Merkheft',
    'Absenzen',
    'Kalender',
    'Noten',
    'Mitteilungen',
    'Profil'
  ];

  Widget _options(BuildContext context, int select) {
    return <Widget>[
      Dashboard().build(context),
      Absences().build(context),
      Calendar().build(context),
      Subjects().build(context),
      Messages().build(context),
      Profile().build(context)
    ][select];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  TabController _tabController;

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Digitales Register'), actions: <Widget>[
        PopupMenuButton<String>(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
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
        )
      ]),
      body: Center(child: _options(context, _selectedIndex)),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        unselectedLabelColor: Colors.grey,
        labelColor: _themeChanger.getColor(),
        isScrollable: true,
        onTap: (index) => _onItemTapped(index),
        tabs: new List.generate(options.length, (index) {
          return new Tab(text: options[index].toUpperCase());
        }),
      ),
    );
  }

  Future<void> logout() async {
    await Session().get('https://fallmerayer.digitalesregister.it/v2/logout');
  }

  void choiceAction(String choice) {
    if (choice == Constants.Setting) {
      Navigator.push(context, PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Settings(),
          transitionDuration: Duration(milliseconds: 100)
      ));
    } else if (choice == Constants.Logout) {
      logout();
      Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => LoginPage(),
              transitionDuration: Duration(milliseconds: 100)),
              (route) => false);
    }
  }
}
