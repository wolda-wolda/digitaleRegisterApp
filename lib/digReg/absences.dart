import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';

class Absences {


  Widget build(BuildContext context) {
    return DrawAbsences();
  }
}
class DrawAbsences extends StatefulWidget{
  @override
  DrawAbsencesState createState() => DrawAbsencesState();
}
class DrawAbsencesState extends State<DrawAbsences>{

  Future<bool> update() async {
    if (Data.firstaccess["absences"]) {
      if (await Data().updateAbsences() == false) {
        if (await Data().loadAbsences() == false) {
          print('Error');
          return false;
        }
      }
      Data.firstaccess["absences"] = false;
    }
    return true;
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
      return Icon(Icons.check_circle, color: Colors.green);
    } else if (data.justified == 3) {
      return Icon(Icons.warning, color: Colors.redAccent);
    } else {
      return Icon(Icons.circle, color: Colors.orange);
    }
  }
  Future<void> refresh() async{
    bool success =await Data().updateAbsences();
    Data.firstaccess["absences"] = Data.firstaccess["absences"]==true?!success:false;
    return;
  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          await refresh();
          setState((){});
          return Future.value(true);
        },
        child: FutureBuilder(
            future: update(),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data == true) {
                String data = Data.absences;
                if (get == true) {
                  items.clear();
                  for (var i in jsonDecode(data)['absences']) {
                    items.add(Absence.fromJson(i));
                  }
                  get = false;
                }
                return Column(
                  children: [
                    ExpansionTileCard(
                        title: Text(
                            'Fehleinheiten: ' +
                                jsonDecode(data)['statistics']['counter']
                                    .toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('davon Entschuldigt: ' +
                            jsonDecode(data)['statistics']['justified']
                                .toString()),
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text('davon im Auftrag der Schule: ' +
                                  jsonDecode(data)['statistics']
                                  ['counterForSchool']
                                      .toString() +
                                  '\nAbwesenheit: ' +
                                  jsonDecode(data)['statistics']
                                  ['percentage'].toString() +
                                  '%' +
                                  '\nNicht entschuldigt: ' +
                                  jsonDecode(data)['statistics']
                                  ['notJustified']
                                      .toString() +
                                  '\nVerspätungen: ' +
                                  jsonDecode(data)['statistics']['delayed']
                                      .toString()),
                            ),
                          ),
                        ]),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: ListView.builder(
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
                                  subtitle: Text(items[index].hour.length
                                      .toString() +
                                      ' Einheiten'),
                                  onTap: () => showAb(context, items[index]),
                                ));
                          },
                        ))
                  ],
                );
              } else if (snapshot.data == null) {
                return Loading();
              }
              else {
                return NoConnection();
              }
            }
        ));
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
        date: Date.format(json['date']),
        hour: temp,
        reason: json['reason'],
        justified: json['justified']);
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

  String reason(Absence data) {
    if (data.reason != null) {
      return data.reason;
    } else {
      return ' ';
    }
  }

  final Absence data;
  PopUpDialog(this.data);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(text(data)),
      content: SingleChildScrollView(
        child: Text(reason(data)),
      ),
    );
  }
}
