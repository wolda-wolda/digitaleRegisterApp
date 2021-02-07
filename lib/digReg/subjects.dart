import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Subjects {
  Future<String> getData1() async {
    return await Session().get(
        'https://fallmerayer.digitalesregister.it/v2/api/student/all_subjects');
  }

  Future<String> getData2(int id, int studentId) async {
    return await Session().post(
        'https://fallmerayer.digitalesregister.it/v2/api/student/subject_detail',
        {'subjectId': id, 'studentId': studentId});
  }

  var items = List<Subject>();
  bool getS = true;

  void showSub(BuildContext context, Grades data) {
    showDialog(
        context: context,
        builder: (context) {
          return PopUpDialog(data);
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getData1(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            if (getS == true) {
              for (var i in jsonDecode(snapshot.data)['subjects']) {
                items.add(Subject.fromJson(i));
              }
              getS = false;
            }
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index1) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                      title: Text(items[index1].name.toString()),
                      children: <Widget>[
                        FutureBuilder<String>(
                            future: getData2(
                                items[index1].id, items[index1].studentId),
                            builder: (context, AsyncSnapshot<String> sub) {
                              if (sub.hasData &&
                                  sub.connectionState == ConnectionState.done) {
                                if (items[index1].getG == true) {
                                  items[index1].grades =
                                      Content.fromJson(jsonDecode(sub.data));
                                }
                                return Column(
                                  children: [
                                    ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: items[index1]
                                            .grades
                                            .observations
                                            .length,
                                        itemBuilder: (context, index2) {
                                          return ListTile(
                                              title: Text(items[index1]
                                                  .grades
                                                  .observations[index2]
                                                  .type
                                                  .toString()));
                                        }),
                                    ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            items[index1].grades.grades.length,
                                        itemBuilder: (context, index2) {
                                          return ListTile(
                                            title: Text(items[index1]
                                                    .grades
                                                    .grades[index2]
                                                    .type
                                                    .toString() +
                                                ': ' +
                                                items[index1]
                                                    .grades
                                                    .grades[index2]
                                                    .grade
                                                    .toString() +
                                                ' - ' +
                                                items[index1]
                                                    .grades
                                                    .grades[index2]
                                                    .weight
                                                    .toString() +
                                                '%'),
                                            onTap: () => showSub(
                                                context,
                                                items[index1]
                                                    .grades
                                                    .grades[index2]),
                                          );
                                        })
                                  ],
                                );
                              } else {
                                return Center();
                              }
                            })
                      ]),
                );
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

class Subject {
  final String name;
  final int absences;
  final int id;
  final int studentId;
  Content grades = Content();
  bool getG = true;

  Subject({this.name, this.absences, this.id, this.studentId});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
        name: json['subject']['name'],
        absences: json['absences'],
        id: json['subjectId'],
        studentId: json['student']['id']);
  }
}

class Content {
  final List<Grades> grades;
  final List<Observations> observations;

  Content({this.grades, this.observations});

  factory Content.fromJson(Map<String, dynamic> json) {
    List<Grades> tempG = [];
    List<Observations> tempO = [];
    for (var i in json['grades']) {
      tempG.add(Grades.fromJson(i));
    }
    for (var i in json['observations']) {
      tempO.add(Observations.fromJson(i));
    }
    return Content(grades: tempG, observations: tempO);
  }
}

class Grades {
  final String grade;
  final int weight;
  final String date;
  final String type;
  final String name;
  final String description;

  Grades(
      {this.grade,
      this.weight,
      this.date,
      this.type,
      this.name,
      this.description});

  factory Grades.fromJson(Map<String, dynamic> json) {
    return Grades(
        grade: json['grade'],
        weight: json['weight'],
        date: json['date'],
        type: json['typeName'],
        name: json['name'],
        description: json['description']);
  }
}

class Observations {
  final String date;
  final String type;

  Observations({this.date, this.type});

  factory Observations.fromJson(Map<String, dynamic> json) {
    return Observations(date: json['date'], type: json['typeName']);
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
