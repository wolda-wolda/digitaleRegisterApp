import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/digReg/absences.dart';
import 'package:digitales_register_app/digReg/dashboard.dart';
import 'package:digitales_register_app/digReg/login_page.dart';
import 'package:digitales_register_app/digReg/messages.dart';
import 'package:digitales_register_app/digReg/profile.dart';
import 'package:digitales_register_app/digReg/settings.dart';
import 'package:digitales_register_app/digReg/subjects.dart';
import 'package:flutter/material.dart';
import 'package:digitales_register_app/digReg/absences.dart';
import 'package:intl/date_symbol_data_local.dart';

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
      Text('Kalender',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          )),
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
    return Scaffold(
      appBar: AppBar(title: Text('Digitales Register'), actions: <Widget>[
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
        )
      ]),
      body: Center(child: _options(context, _selectedIndex)),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        unselectedLabelColor: Colors.grey[600],
        labelColor: const Color(0xFF3baee7),
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
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Settings();
      }));
    } else if (choice == Constants.Logout) {
      logout();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
              (route) => false);
    }
  }
}
