import 'package:digitales_register_app/digReg/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'PopUpMenu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  List<String> options = <String>[
    'Merkheft',
    'Absenzen',
    'Kalender',
    'Noten',
    'Mitteilungen',
    'Zeugnis',
    'Profil'
  ];
  List<Widget> _options = <Widget>[
    Text('Merkheft', style: TextStyle(fontWeight: FontWeight.bold,)),
    Text('Absenzen', style: TextStyle(fontWeight: FontWeight.bold,)),
    Text('Kalender', style: TextStyle(fontWeight: FontWeight.bold,)),
    Text('Noten', style: TextStyle(fontWeight: FontWeight.bold,)),
    Text('Mitteilungen', style: TextStyle(fontWeight: FontWeight.bold,)),
    Text('Zeugnis', style: TextStyle(fontWeight: FontWeight.bold,)),
    Text('Profil', style: TextStyle(fontWeight: FontWeight.bold,)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _options.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digitales Register'),
        actions: <Widget>[
      PopupMenuButton<String>(
      onSelected: choiceAction,
        itemBuilder: (BuildContext context){
          return Constants.choices.map((String choice){
            if(choice == Constants.Setting)
            {
              return PopupMenuItem<String>(
                value: choice,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.settings_applications, color: Colors.grey,),
                    Text(choice),
                  ],
                ),
              );
            }
            else if(choice == Constants.Exit)
            {
              return PopupMenuItem<String>(
                value: choice,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.exit_to_app, color: Colors.grey,),
                    Text(choice),
                  ],
                ),
              );
            }
          }).toList();
        },
      )
      ]),
      body: Center(child: _options.elementAt(_selectedIndex)),
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
  void choiceAction(String choice){
    if(choice == Constants.Setting){
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Settings();
      }));
    }
    else if(choice == Constants.Exit)
    {
      SystemNavigator.pop();
      return ;
    }
  }
}

