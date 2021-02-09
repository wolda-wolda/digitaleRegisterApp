import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class Calendar {
  DateTime setWeek(int addNow) {
    DateTime now = DateTime.now();
    addNow = addNow - 50;
    print(addNow);
    return DateTime(now.year, now.month, now.day + addNow*7);
  }

  Future<String> getData(DateTime week) async {
    if (week.weekday == 6) {
      week = week.add(Duration(days: 2));
    } else if (week.weekday == 7) {
      week = week.add(Duration(days: 1));
    } else {
      while (week.weekday != 1) {
        week = week.subtract(Duration(days: 1));
      }
    }
    print(week);
    String monday = DateFormat('y-MM-dd').format(week);
    return await Session().post(
        'https://fallmerayer.digitalesregister.it/v2/api/calendar/student',
        {'startDate': monday});
  }

  void showLesson(BuildContext context, Lesson data) {
    showDialog(
        context: context,
        builder: (context) {
          return PopUpDialog(data);
        });
  }

  var items = List<Day>();
  List week = [];
  bool get = true;
  bool linked = false;
  final controller = PageController(initialPage: 50);

  String hour(Lesson data) {
    if (data.linkedHours == 1) {
      if (linked == false) {
        linked = true;
        return data.hour.toString();
      } else {
        linked = false;
        return (data.hour + 1).toString();
      }
    }
    linked = false;
    return data.hour.toString();
  }

  Widget build(BuildContext context) {
    return PageView.builder(
        itemCount: 100,
        controller: controller,
        itemBuilder: (BuildContext context, int index) {
          items.clear();
          get = true;
          return FutureBuilder<String>(
              future: getData(setWeek(index)),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  if (get == true) {
                    week = jsonDecode(snapshot.data).keys.toList();
                    for (var i in week) {
                      items.add(Day.fromJson(jsonDecode(snapshot.data)[i]['1']['1']));
                    }
                    get = false;
                  }
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: week.length,
                    itemBuilder: (context, index1) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                              Date.format(jsonDecode(snapshot.data)
                                  .keys
                                  .toList()[index1])
                                  .date,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: items[index1].list.length,
                            itemBuilder: (context, index2) {
                              return ListTile(
                                leading: Text(hour(items[index1].list[index2])),
                                title: Text(items[index1].list[index2].subject,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                onTap: () => showLesson(
                                    context, items[index1].list[index2]),
                              );
                            },
                          ),
                        ),
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
        });
  }
}

class Day {
  final List<Lesson> list;

  Day({this.list});

  factory Day.fromJson(Map<String, dynamic> json) {
    List<Lesson> temp = [];
    for (var i in json.keys) {
      if (json[i.toString()]['lesson'] != null) {
        temp.add(Lesson.fromJson(json[i.toString()]));
        if (json[i.toString()]['linkedHoursCount'] == 1) {
          temp.add(Lesson.fromJson(json[i.toString()]));
        }
      }
    }
    return Day(list: temp);
  }
}

class Lesson {
  final int hour;
  final bool isLesson;
  final String subject;
  final List<String> teachers;
  final List<String> rooms;
  final int linkedHours;

  Lesson(
      {this.hour,
      this.isLesson,
      this.subject,
      this.teachers,
      this.rooms,
      this.linkedHours});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    bool intToBool(int i) {
      if (i == 1) {
        return true;
      } else {
        return false;
      }
    }

    List<String> tempT = List<String>();
    for (var i in json['lesson']['teachers']) {
      tempT.add(i['lastName'] + ' ' + i['firstName']);
    }
    List<String> tempR = List<String>();
    for (var i in json['lesson']['rooms']) {
      tempR.add(i['name']);
    }
    return Lesson(
        hour: json['hour'],
        isLesson: intToBool(json['isLesson']),
        subject: json['lesson']['subject']['name'],
        teachers: tempT,
        rooms: tempR,
        linkedHours: json['linkedHoursCount']);
  }
}

class PopUpDialog extends StatelessWidget {
  final Lesson data;

  PopUpDialog(this.data);

  String teacher(Lesson teacher) {
    if (teacher.teachers.isNotEmpty) {
      String ret = '';
      for (var i in teacher.teachers) {
        ret = ret + '\n' + i;
      }
      return ret;
    }
    return '';
  }

  String rooms(Lesson room) {
    if (room.rooms.isNotEmpty) {
      String ret = '';
      for (var i in room.rooms) {
        ret = ret + '\n' + i;
      }
      return ret;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(data.subject),
      content: SingleChildScrollView(
          child: Column(
        children: [
          ListTile(title: Text('Lehrperson/en'), subtitle: Text(teacher(data))),
          Padding(padding: EdgeInsets.only(top: 25)),
          ListTile(title: Text('Raum'), subtitle: Text(rooms(data)))
        ],
      )),
    );
  }
}