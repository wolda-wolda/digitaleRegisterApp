import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';
import 'package:digitales_register_app/theme/theme.dart';
import 'package:provider/provider.dart';

class Subjects {
  Widget build(BuildContext context) {
    return DrawSubjects();
  }
}
class DrawSubjects extends StatefulWidget{
  @override
  DrawSubjectsState createState() => DrawSubjectsState();
}
class DrawSubjectsState extends State<DrawSubjects>{

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



  Text average(double ave) {
    if (ave.isNaN) return Text('Durchschnitt: /');
    return Text('Durchschnitt: ' + ave.toString());
  }

  Future<void> refresh() async{
    bool success =await Data().updateSubjects();
    Detail.firstaccess2=true;
    firstaccess = firstaccess==true?!success:false;
    return;
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

  @override
  Widget build(BuildContext context){
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
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
                SizedBox(
                  height: 25,
                ),
                ListTile(
                  title: Text('Gesamtdurchschnitt: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                  trailing: Container(
                      height: 50,
                      width: 70,
                      child: Column(
                        children: [
                          Transform(
                            transform: Matrix4.translationValues(0, 15, 0),
                            child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: _themeChanger.getColor(),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(total_average(Data.subjectitems)
                                      .toStringAsPrecision(3),style: TextStyle(fontSize: 15),),
                                )
                            ),
                          )
                        ],
                      )
                  ),
                  selectedTileColor: Colors.grey[800],
                ),
                Divider(
                  height: 30,
                  endIndent: 150,
                  indent: 150,
                  thickness: 2,
                  color: _themeChanger.getColor(),
                ),
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
                                Detail(index1,Data.subjectitems),
                              ]);
                        }))
              ],
            );
          } else if (snapshot.data == null) {
            return Loading();
          } else {
            return NoConnection();
          }
        })
    );
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
class Detail extends StatelessWidget{
  final List subjectitems;
  final int index1;
  Detail(this.index1,this.subjectitems);
  static Map<int,bool> loaded={};
  static bool firstaccess2=true;
  void initload(){
      for(var i=0;i<subjectitems.length;i++){
        loaded[i]=false;
      }
    return;
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
  Future<bool> updateDetail(index) async{
    if(firstaccess2==true){
      initload();
      firstaccess2=false;
    }
    if(loaded[index]==false) {
      if (await Data().updateSubjectDetail(index, index) == false) {
        if (await Data().loadSubjectDetail(index, index) == false) {
          print('Error');
          return false;
        }
      }
      loaded[index] = true;
    }
    return true;
  }
  Widget build(BuildContext context) {
    if(subjectitems[index1].tempGrades.isNotEmpty){
      return FutureBuilder(
          future: updateDetail(index1),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == true) {
              return Column(
                  children: [
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: subjectitems[index1]
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
                        itemCount: subjectitems[index1]
                            .content.grades.length,
                        itemBuilder: (context, index2) {
                          return ListTile(
                            title: Text(subjectitems[index1]
                                .content.grades[index2].type
                                .toString() +
                                ': ' +
                                note(subjectitems[index1]
                                    .content.grades[index2]) +
                                ' - ' +
                                subjectitems[index1].content
                                    .grades[index2].weight
                                    .toString() +
                                '%'),
                            onTap: () =>
                                showSub(
                                    context,
                                    subjectitems[index1].content
                                        .grades[index2]),
                          );
                        })
                  ]
              );
            }
            else if (snapshot.data == null) {
              return LoadingBar();
            } else {
              return Container();
            }
          }
      );
  }else{
      return Container();
    }
  }
}