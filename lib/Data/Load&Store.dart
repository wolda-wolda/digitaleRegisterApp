import 'package:digitales_register_app/API/API.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

class Data {
  static String profile;
  static String absences;
  static String calendar;
  static String dashboard;
  static String subjects;
  static String data2;
  static String messages;
  static String subjectdetail;
  var id;
  var studentId;
  static var items = List<Subject>();

  Future<void> updateall() async {

    final preferences = await SharedPreferences.getInstance();
    preferences.setString('profile', await Session().get('https://fallmerayer.digitalesregister.it/v2/api/profile/get'));
    preferences.setString('absences', await Session().get('https://fallmerayer.digitalesregister.it/v2/api/student/dashboard/absences'));
    preferences.setString('calendar', await Session().post('https://fallmerayer.digitalesregister.it/v2/api/calendar/student', {'startDate': '2021-02-08'}));
    preferences.setString('dashboard', await Session().post('https://fallmerayer.digitalesregister.it/v2/api/student/dashboard/dashboard', {'viewFuture': true}));
    preferences.setString('subjects', await Session().get('https://fallmerayer.digitalesregister.it/v2/api/student/all_subjects'));
    preferences.setString('messages', await Session().post('https://fallmerayer.digitalesregister.it/v2/api/message/getMyMessages', {'filterByLabelName': ''}));

    profile = preferences.getString('profile');
    absences = preferences.getString('absences');
    calendar = preferences.getString('calendar');
    dashboard = preferences.getString('dashboard');
    subjects = preferences.getString('subjects');
    messages = preferences.getString('messages');

    for (var i in jsonDecode(subjects)['subjects']) {
      items.add(Subject.fromJson(i));
    }
    for (var i=0;i< items.length;i++){
      id = items[i].id;
      studentId = items[i].studentId;
      subjectdetail =  await Session().post('https://fallmerayer.digitalesregister.it/v2/api/student/subject_detail', {'subjectId': id, 'studentId': studentId});
      items[i].grades = Content.fromJson(jsonDecode(subjectdetail));
    }


    return;
  }
}

