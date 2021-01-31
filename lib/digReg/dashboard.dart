import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class Dashboard {
  Future<String> getData() async {
    String data = await Session().post(
        'https://fallmerayer.digitalesregister.it/v2/api/student/dashboard/dashboard',
        {'viewFuture': true});
    return data;
  }

  var items = List<Dash>();
  bool get = true;

  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getData(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            if (get == true) {
              for (var i in jsonDecode(snapshot.data)) {
                items.add(Dash.fromJson(i));
              }
              get = false;
            }
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index1) {
                return ListTile(
                    title: Text(items[index1].date.toString()),
                    subtitle: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: items[index1].items.length,
                      itemBuilder: (context, index2) {
                        return ListTile(
                          title: title(context, items[index1], index2),
                          subtitle: Text(
                              items[index1].items[index2].subtitle.toString()),
                        );
                      },
                    ));
              },
            );
          }
          return Center(
            child: Text("LOADING...",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
          );
        });
  }
}

Widget title(BuildContext context, Dash item, int index2) {
  if (item.items[index2].label != null)
    return Text(item.items[index2].title.toString() +
        ' - ' +
        item.items[index2].label.toString());
  return Text(item.items[index2].title.toString());
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

class Date {
  final String date;
  Date(this.date);

  factory Date.format(String enDate) {
    DateTime date = new DateFormat('yyyy-MM-dd').parse(enDate);

    return Date(
        DateFormat('EEEE, d. MMM yyyy', 'de_DE').format(date).toString());
  }
}
