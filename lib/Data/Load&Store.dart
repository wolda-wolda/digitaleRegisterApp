import 'package:digitales_register_app/API/API.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class Subject {
  final String name;
  final int absences;
  final int id;
  final int studentId;
  final List<Grades> tempGrades;
  double average;
  Content content = Content();
  bool getG = true;

  Subject({this.name, this.absences, this.id, this.studentId, this.tempGrades});

  factory Subject.fromJson(Map<String, dynamic> json) {
    List<Grades> temp = List<Grades>();
    for (var i in json['grades']) {
      temp.add(Grades(
          grade: i['grade'],
          weight: i['weight'],
          date: i['date'],
          type: i['type'],
          name: i['name'],
          description: i['description']));
    }
    return Subject(
        name: json['subject']['name'],
        absences: json['absences'],
        id: json['subjectId'],
        studentId: json['student']['id'],
        tempGrades: temp);
  }
}

class Content {
  List<Grades> grades = List<Grades>();
  List<Observations> observations = List<Observations>();

  Content({this.grades, this.observations});

  factory Content.fromJson(Map<String, dynamic> json) {
    List<Grades> tempG = List<Grades>();
    List<Observations> tempO = List<Observations>();
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

DateTime setWeek(int addNow) {
  DateTime now = DateTime.now();
  addNow = addNow - 50;
  print(addNow);
  return DateTime(now.year, now.month, now.day + addNow*7);
}
class Data {
  static String profile;
  static String absences;
  static String dashboard;
  static String subjects;
  static String data2;
  static String messages;
  static String subjectdetail;
  static List week;
  static List week2;
  static bool subjectcreated=false;
  static String calendardetail;
  static bool firsttime = false;
  static var Length;
  static var id;
  static var studentId;
  static var subjectitems = List<Subject>();
  static var calendaritems = List<Day>();
  static final Map<int, String> calendar = {};
  static String link = 'https://fallmerayer.digitalesregister.it';

  Future<bool> updateAll() async {
    print('updateDashboard');
    await Data().updateDashboard();
    print('updateProfile');
    await Data().updateProfile();
    print('updateAbsences');
    await Data().updateAbsences();
    print('updateCalendar');
    await Data().updateCalendar(49,51);
    print('updateSubjects');
    await Data().updateSubjects();
    print('updateMessages');
    await Data().updateMessages();
      return true;
    }
  Future<bool> updateProfile() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('profile', await Session().get(
        link + '/v2/api/profile/get'));
    await Data().loadProfile();
    return true;
  }
  Future<bool> updateAbsences() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('absences', await Session().get(
        link + '/v2/api/student/dashboard/absences'));
    await Data().loadAbsences();
    return true;
  }
  Future<bool> updateCalendar(var from, var to) async {
      final preferences = await SharedPreferences.getInstance();
      for( var i=from;i<=to;i++) {
        DateTime week = setWeek(i);
        if (week.weekday == 6) {
          week = week.add(Duration(days: 2));
        } else if (week.weekday == 7) {
          week = week.add(Duration(days: 1));
        } else {
          while (week.weekday != 1) {
            week = week.subtract(Duration(days: 1));
          }
        }
        String monday = DateFormat('y-MM-dd').format(week);
        preferences.setString('calendardetail' + i.toString(), await Session().post(link + '/v2/api/calendar/student', {'startDate': monday}));
        calendardetail = preferences.getString('calendardetail' + i.toString());
        calendar[i] = calendardetail;
      }

      return true;
  }
  Future<bool> updateDashboard() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('dashboard', await Session().post(
        link + '/v2/api/student/dashboard/dashboard',
        {'viewFuture': true}));
    await Data().loadDashboard();
    return true;
  }
  Future<bool> updateSubjects() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('subjects', await Session().get(link + '/v2/api/student/all_subjects'));
    subjects = preferences.getString('subjects');
    if(subjectcreated==false) {
      for (var i in jsonDecode(subjects)['subjects']) {
        subjectitems.add(Subject.fromJson(i));
      }
      Length=subjectitems.length;
      subjectcreated=true;
    }
    for (var i = 0; i < subjectitems.length; i++) {
      id = subjectitems[i].id;
      studentId = subjectitems[i].studentId;
      subjectdetail = await Session().post(link + '/v2/api/student/subject_detail', {'subjectId': id, 'studentId': studentId});
      preferences.setString("subjectdetail" + i.toString(), subjectdetail);
      subjectitems[i].content = Content.fromJson(jsonDecode(subjectdetail));
    }
    return true;
  }
  Future<bool> updateMessages() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('messages', await Session().post(
        link + '/v2/api/message/getMyMessages',
        {'filterByLabelName': ''}));
    await Data().loadMessages();
    return true;
  }

  Future<bool> loadAll() async {
      print('loadProfile');
      await Data().loadProfile();
      print('loadAbsences');
      await Data().loadAbsences();
      print('loadCalendar');
      await Data().loadCalendar(49,51);
      print('loadDashboard');
      await Data().loadDashboard();
      print('loadMessages');
      await Data().loadMessages();
      print('loadSubjects');
      await Data().loadSubjects();
      return true;
  }
  Future<bool> loadProfile() async {
    final preferences = await SharedPreferences.getInstance();
    if(preferences.containsKey('profile')==false){
          return false;
    }
    profile = preferences.getString('profile');
    return true;
  }
  Future<bool> loadAbsences() async {
    final preferences = await SharedPreferences.getInstance();
    if(preferences.containsKey('absences')==false){
      return false;
    }
    absences = preferences.getString('absences');
    return true;
  }
  Future<bool> loadCalendar(var from, var to) async {
    final preferences = await SharedPreferences.getInstance();
    var i = 0;
    for(i=from;i<=to;i++) {
      if(preferences.containsKey('calendardetail' + i.toString())) {
        calendardetail = preferences.getString('calendardetail' + i.toString());
        calendar[i] = calendardetail;
      }
    }
    return true;
  }
  Future<bool> loadDashboard() async {
    final preferences = await SharedPreferences.getInstance();
    if(preferences.containsKey('dashboard')==false){
      return false;
    }
    dashboard = preferences.getString('dashboard');
    return true;
  }
  Future<bool> loadMessages() async {
    final preferences = await SharedPreferences.getInstance();
    if(preferences.containsKey('messages')==false){
      return false;
    }
    messages = preferences.getString('messages');
    return true;
  }
  Future<bool> loadSubjects() async {
    final preferences = await SharedPreferences.getInstance();
    if(preferences.containsKey('subjects')==false){
      return false;
    }
    subjects = preferences.getString('subjects');

    if(subjectcreated==false) {
      for (var i in jsonDecode(subjects)['subjects']) {
        subjectitems.add(Subject.fromJson(i));
      }
      Length=subjectitems.length;
      subjectcreated=true;
    }
    for (var i = 0; i < Length; i++) {
      id = subjectitems[i].id;
      studentId = subjectitems[i].studentId;
      subjectdetail = preferences.getString("subjectdetail" + i.toString());
      subjectitems[i].content = Content.fromJson(jsonDecode(subjectdetail));
    }
    return true;
  }

}

