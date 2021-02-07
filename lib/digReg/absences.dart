import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Absences {
  Future<String> getData() async {
    return await Session().get(
        'https://fallmerayer.digitalesregister.it/v2/api/student/dashboard/absences');
  }

  var items = List<Absence>();
  bool get = true;

  void showAb(BuildContext context, Absence data) {
    showDialog(
        context: context,
        builder: (context) {
          return PopUpDialog(data);
        });
  }

  Icon icon(Absence data) {
    if (data.justified == 2) {
      return Icon(Icons.check_circle);
    }
    else {
      return Icon(Icons.circle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getData(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            if (get == true) {
              for (var i in jsonDecode(snapshot.data)['absences']) {
                items.add(Absence.fromJson(i));
              }
              get = false;
            }
            return Column(
              children: [
                Text('Fehleinheiten: ' + jsonDecode(snapshot.data)['statistics']['counter'].toString()),
                Text('davon im Auftrag der Schule: ' + jsonDecode(snapshot.data)['statistics']['counterForSchool'].toString()),
                Text('Abwesenheit: ' + jsonDecode(snapshot.data)['statistics']['percentage'] + '%'),
                Text('Entschuldigt: ' + jsonDecode(snapshot.data)['statistics']['justified'].toString()),
                Text('Nicht entschuldigt: ' + jsonDecode(snapshot.data)['statistics']['notJustified'].toString()),
                Text('Verspätungen: ' + jsonDecode(snapshot.data)['statistics']['delayed'].toString()),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: icon(items[index]),
                          title: Text(items[index].date.date +
                              ', ' +
                              items[index]
                                  .hour[items[index].hour.length - 1]
                                  .hour
                                  .toString() +
                              '. Stunde'),
                          subtitle: Text(items[index].hour.length.toString() +
                              ' Einheiten'),
                          onTap: () => showAb(context, items[index]),
                        ));
                  },
                )
              ],
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

class Absence {
  final Date date;
  final List<Group> hour;
  final String reason;
  final int justified;

  Absence({this.date, this.hour, this.reason, this.justified});

  factory Absence.fromJson(Map<String, dynamic> json) {
    List<Group> temp = [];
    for (var i in json['group']) {
      temp.add(Group.fromJson(i));
    }
    return Absence(
        date: Date.format(json['date']), hour: temp, reason: json['reason'], justified: json['justified']);
  }
}

class Group {
  final int hour;

  Group({this.hour});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(hour: json['hour']);
  }
}

class PopUpDialog extends StatelessWidget {
  String text(Absence txt) {
    if (txt.hour.length - 1 == 0) {
      return data.date.date + "\n" + data.hour[0].hour.toString() + '. Stunde';
    } else {
      return data.date.date +
          "\n" +
          data.hour[data.hour.length - 1].hour.toString() +
          '. - ' +
          data.hour[0].hour.toString() +
          '. Stunde';
    }
  }

  final Absence data;
  PopUpDialog(this.data);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(text(data)),
      content: SingleChildScrollView(
        child: Text(data.reason),
      ),
    );
  }
}
