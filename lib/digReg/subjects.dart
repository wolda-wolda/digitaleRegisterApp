import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';

class Subjects {
  static bool firstaccess = true;
  Future<bool> update() async {
    if (firstaccess) {
      if (await Data().updateSubjects() == false) {
        if (await Data().loadSubjects() == false) {
          print('Error');
          return false;
        }
      }
      firstaccess = false;
    }
    return true;
  }

  void showSub(BuildContext context, Grades data) {
    showDialog(
        context: context,
        builder: (context) {
          return PopUpDialog(data);
        });
  }

  String note(Grades data) {
    List<String> format = data.grade.split('.');
    String ret;
    if (format[1] == '00')
      ret = format[0];
    else if (format[1] == '25')
      ret = format[0] + '+';
    else if (format[1] == '50')
      ret = format[0] + '/' + (int.parse(format[0]) + 1).toString();
    else if (format[1] == '75')
      ret = (int.parse(format[0]) + 1).toString() + '-';
    else
      ret = data.grade;
    return ret;
  }

  Text average(double ave) {
    if (ave.isNaN) return Text('Durchschnitt: /');
    return Text('Durchschnitt: ' + ave.toString());
  }

  double total_average(List<Subject> data) {
    double divident = 0;
    int divisor = 0;
    for (var i in data) {
      if (i.average != null) {
        if (!i.average.isNaN) {
          divident += i.average;
          divisor++;
        }
      }
    }
    return divident / divisor;
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: update(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == true) {
            for(var i = 0;i<Data.subjectitems.length;i++){
              double dividend = 0;
              double divisor = 0;
              for (var i in Data.subjectitems[i].tempGrades) {
                dividend = dividend +
                    double.parse(i.grade) * i.weight / 100;
                divisor = divisor + i.weight / 100;
              }
              Data.subjectitems[i].average = double.parse(
                  (dividend / divisor).toStringAsPrecision(3));
            }
            return Column(
              children: [
                ListTile(
                    title: Text('Gesamtdurchschnitt: ' +
                        total_average(Data.subjectitems)
                            .toStringAsPrecision(3)),
                    selectedTileColor: Colors.grey[800]),
                Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: Data.subjectitems.length,
                        itemBuilder: (context, index1) {
                          return ExpansionTileCard(
                              borderRadius: BorderRadius.circular(10),
                              title: Text(
                                  Data.subjectitems[index1].name.toString(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle:
                                  average(Data.subjectitems[index1].average),
                              children: <Widget>[
                                Divider(
                                  thickness: 1.0,
                                  height: 1.0,
                                ),
                                Column(children: [
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: Data.subjectitems[index1]
                                          .content.observations.length,
                                      itemBuilder: (context, index2) {
                                        return ListTile(
                                            title: Text(Data
                                                .subjectitems[index1]
                                                .content
                                                .observations[index2]
                                                .type
                                                .toString()));
                                      }),
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: Data.subjectitems[index1]
                                          .content.grades.length,
                                      itemBuilder: (context, index2) {
                                        return ListTile(
                                          title: Text(Data.subjectitems[index1]
                                                  .content.grades[index2].type
                                                  .toString() +
                                              ': ' +
                                              note(Data.subjectitems[index1]
                                                  .content.grades[index2]) +
                                              ' - ' +
                                              Data.subjectitems[index1].content
                                                  .grades[index2].weight
                                                  .toString() +
                                              '%'),
                                          onTap: () => showSub(
                                              context,
                                              Data.subjectitems[index1].content
                                                  .grades[index2]),
                                        );
                                      })
                                ])
                              ]);
                        }))
              ],
            );
          } else if (snapshot.data == null) {
            return Loading();
          } else {
            return NoConnection();
          }
        });
  }
}

class PopUpDialog extends StatelessWidget {
  final Grades data;
  PopUpDialog(this.data);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(data.type + ": " + data.grade),
      content: SingleChildScrollView(
        child: Text(data.description),
      ),
    );
  }
}
