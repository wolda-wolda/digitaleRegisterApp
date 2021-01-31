import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Subjects {
  Future<String> getData() async {
    String data = await Session().get(
        'https://fallmerayer.digitalesregister.it/v2/api/student/all_subjects');
    return data;
  }

  var items = List<Subject>();
  bool get = true;

  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getData(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            if (get == true) {
              for (var i in jsonDecode(snapshot.data)['subjects']) {
                items.add(Subject.fromJson(i));
              }
              get = false;
            }
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index1) {
                return ListTile(
                    title: Text(items[index1].name.toString()),
                    subtitle: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: items[index1].grades.length,
                      itemBuilder: (context, index2) {
                        return ListTile(
                          title: Text(items[index1]
                                  .grades[index2]
                                  .type
                                  .toString() +
                              ': ' +
                              items[index1].grades[index2].grade.toString() +
                              ' - ' +
                              items[index1].grades[index2].weight.toString() +
                              '%'),
                          subtitle:
                              Text(items[index1].grades[index2].description),
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

class Subject {
  final String name;
  final int absences;
  final List<Grades> grades;

  Subject({this.name, this.absences, this.grades});

  factory Subject.fromJson(Map<String, dynamic> json) {
    List<Grades> temp = [];
    for (var i in json['grades']) {
      temp.add(Grades.fromJson(i));
    }
    return Subject(
        name: json['subject']['name'],
        absences: json['absences'],
        grades: temp);
  }
}

class Grades {
  final String grade;
  final int weight;
  final String date;
  final String type;
  final String description;

  Grades({this.grade, this.weight, this.date, this.type, this.description});

  factory Grades.fromJson(Map<String, dynamic> json) {
    return Grades(
        grade: json['grade'],
        weight: json['weight'],
        date: json['date'],
        type: json['type'],
        description: json['description']);
  }
}
