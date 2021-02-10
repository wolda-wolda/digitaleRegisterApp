import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'file:///C:/Users/android/StudioProjects/digitaleRegisterApp/lib/digReg/usefulWidgets.dart';

class Dashboard {
  static bool firstaccess=true;
  Future<bool> update() async {
    if (firstaccess) {
      if (await Data().updateDashboard() == false) {
        if (await Data().loadDashboard() == false) {
          print('Error');
          return false;
        }
      }
      firstaccess = false;
    }
    return true;
  }
  var items = List<Dash>();
  bool get = true;


  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);

        return FutureBuilder(
          future: update(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
              if(snapshot.data==true){
                String data = Data.dashboard;
                if (get == true) {
                  for (var i in jsonDecode(data)) {
                    items.add(Dash.fromJson(i));
                  }
                  get = false;
                }
                return  RefreshIndicator(
                 child: ListView.builder(
                   scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index1) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(items[index1].date.toString(),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),),
                        subtitle: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: items[index1].items.length,
                          itemBuilder: (context, index2) {
                            return ListTile(
                              title: title(context, items[index1], index2),
                              trailing: title2(
                                  context, items[index1], index2, _themeChanger),
                              subtitle: Text(
                                  items[index1].items[index2].subtitle
                                      .toString()),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                  onRefresh: (){
                   return Data().updateDashboard();
                  }
                );

              }else if(snapshot.data==null){
                return Loading();
              }
              else{
                return NoConnection();
              }
          }
    );
          }
}

Widget title(BuildContext context, Dash item, int index2) {
  if (item.items[index2].label != null)
    return Text(item.items[index2].title.toString(),
    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),);
  return Text(item.items[index2].title.toString(),
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),);
}

Widget title2(BuildContext context, Dash item, int index2, ThemeChanger _themeChanger) {
  if (item.items[index2].label != null)
    return Container(
      height: 40,
      width: 130,
      child: Transform(
        transform: Matrix4.translationValues(22, 0.0, 0.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
            color: _themeChanger.getColor(),
          child: Align(
            alignment: Alignment.center,
            child: Text(item.items[index2].label.toString(),textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
          )
        ),
      )
      );
}
class Dash {
  final String date;
  final List<Items> items;

  Dash({this.date, this.items});

  factory Dash.fromJson(Map<String, dynamic> json) {
    List<Items> temp = [];
    for (var i in json['items']) {
      temp.add(Items.fromJson(i));
    }
    return Dash(date: Date.format(json['date']).date, items: temp);
  }
}


class Items {
  final String title;
  final String subtitle;
  final String label;
  final bool checkable;
  final bool checked;
  final bool deletable;
  final bool warning;
  final String type;
  final int id;

  Items(
      {this.subtitle,
      this.title,
      this.label,
      this.checkable,
      this.checked,
      this.deletable,
      this.warning,
      this.type,
      this.id});

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
        subtitle: json['subtitle'],
        title: json['title'],
        label: json['label'],
        checkable: json['checkable'],
        checked: json['checked'],
        deletable: json['deleteable'],
        warning: json['warning'],
        type: json['type'],
        id: json['id']
    );
  }
}
