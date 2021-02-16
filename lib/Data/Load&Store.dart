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

class Unread {
  final String title;
  final String subTitle;
  final String timeSent;
  final String type;

  Unread({this.title, this.subTitle, this.timeSent, this.type});

  factory Unread.fromJson(Map<String, dynamic> json) {
    return Unread(
        title: json['title'],
        subTitle: json['subTitle'],
        timeSent: Date.format(json['timeSent']).date,
        type: json['type']
    );
  }
}

DateTime setWeek(int addNow) {
  DateTime now = DateTime.now();
  addNow = addNow - 50;
  print(addNow);
  return DateTime(now.year, now.month, now.day + addNow * 7);
}

class Data {
  static String profile;
  static String absences;
  static String dashboard;
  static String subjects;
  static String data2;
  static String messages;
  static String subjectdetail;
  static String unread;
  static List week;
  static List week2;
  static String cache;
  static String calendardetail;
  static bool firsttime = false;
  static var id;
  static var studentId;
  static var subjectitems = List<Subject>();
  static var subjectitems2 = List<Subject>();
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
    await Data().updateCalendar(49, 51);
    print('updateSubjects');
    await Data().updateSubjects();
    print('updateMessages');
    await Data().updateMessages();
    print('updateUnread');
    await Data().updateUnread();
    return true;
  }

  Future<bool> updateProfile() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().get(link + '/v2/api/profile/get');
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString('profile', cache);
      await Data().loadProfile();
      return true;
    }
  }

  Future<bool> updateAbsences() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().get(link + '/v2/api/student/dashboard/absences');
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString('absences', cache);
      await Data().loadAbsences();
      return true;
    }
  }
  Future<bool> updateUnread() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().get(link + '/v2/api/notification/unread');
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString('unread', cache);
      await Data().loadUnread();
      return true;
    }
  }

  Future<bool> updateCalendar(var from, var to) async {
    final preferences = await SharedPreferences.getInstance();
    for (var i = from; i <= to; i++) {
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
      cache = await Session()
          .post(link + '/v2/api/calendar/student', {'startDate': monday});
      print(cache);
      if (cache == 'e') {
        return false;
      } else {
        preferences.setString('calendardetail' + i.toString(), cache);
        calendar[i] = cache;
      }
    }
    return true;
  }

  Future<bool> updateDashboard() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().post(
        link + '/v2/api/student/dashboard/dashboard', {'viewFuture': true});
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString('dashboard', cache);
      await Data().loadDashboard();
      return true;
    }
  }

  Future<bool> updateSubjects() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().get(link + '/v2/api/student/all_subjects');
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString('subjects', cache);
      subjectitems2.clear();
      subjects = preferences.getString('subjects');
        for (var i in jsonDecode(subjects)['subjects']) {
          subjectitems2.add(Subject.fromJson(i));
        }
        loadSubjectDetail(0,subjectitems.length);
      subjectitems = subjectitems2;
      return true;
    }
  }
  Future<bool> updateSubjectDetail(var from, var to) async{
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('subjects') == null) {
      return false;
    }
    subjects = preferences.getString('subjects');
    for (var i = from; i <= to; i++ ) {
      id = subjectitems[i].id;
      studentId = subjectitems[i].studentId;
      subjectdetail = await Session().post(
          link + '/v2/api/student/subject_detail',
          {'subjectId': id, 'studentId': studentId});
      if(subjectdetail=='e'){
        return false;
      }
      else {
        preferences.setString("subjectdetail" + i.toString(), subjectdetail);
        subjectitems[i].content = Content.fromJson(jsonDecode(subjectdetail));
      }
    }
    return true;
  }

  Future<bool> updateMessages() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().post(
        link + '/v2/api/message/getMyMessages', {'filterByLabelName': ''});
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString('messages', cache);
      await Data().loadMessages();
      return true;
    }
  }

  Future<bool> loadAll() async {
    print('loadProfile');
    await Data().loadProfile();
    print('loadAbsences');
    await Data().loadAbsences();
    print('loadCalendar');
    await Data().loadCalendar(49, 51);
    print('loadDashboard');
    await Data().loadDashboard();
    print('loadMessages');
    await Data().loadMessages();
    print('loadSubjects');
    await Data().loadSubjects();
    print('loadUnread');
    await Data().loadUnread();
    return true;
  }

  Future<bool> loadProfile() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('profile') == null) {
      return false;
    }
    profile = preferences.getString('profile');
    return true;
  }

  Future<bool> loadAbsences() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('absences') == null) {
      return false;
    }
    absences = preferences.getString('absences');
    return true;
  }

  Future<bool> loadCalendar(var from, var to) async {
    final preferences = await SharedPreferences.getInstance();
    for (var i = from; i <= to; i++) {
      if (preferences.containsKey('calendardetail' + i.toString()) &&
          preferences.getString('calendardetail' + i.toString()) != null) {
        calendardetail = preferences.getString('calendardetail' + i.toString());
        calendar[i] = calendardetail;
      } else {
        return false;
      }
    }
    return true;
  }

  Future<bool> loadDashboard() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('dashboard') == null) {
      return false;
    }
    dashboard = preferences.getString('dashboard');
    return true;
  }

  Future<bool> loadMessages() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('messages') == null) {
      return false;
    }
    messages = preferences.getString('messages');
    return true;
  }
  Future<bool> loadUnread() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('unread') == null) {
      return false;
    }
    unread = preferences.getString('unread');
    return true;
  }

  Future<bool> loadSubjects() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString('subjects') == null) {
      return false;
    }
    subjects = preferences.getString('subjects');
    subjectitems.clear();
    for (var i in jsonDecode(subjects)['subjects']) {
      subjectitems.add(Subject.fromJson(i));
    }
    return true;
  }
  Future<bool> loadSubjectDetail(var from, var to) async{
    bool error=false;
    final preferences = await SharedPreferences.getInstance();
    for(var i=from;i<=to;i++) {
      if(preferences.containsKey("subjectdetail" + i.toString())==false || preferences.getString("subjectdetail" + i.toString())==null){
        error=true;
      }
      else {
        subjectdetail = preferences.getString("subjectdetail" + i.toString());
        subjectitems2[i].content = Content.fromJson(jsonDecode(subjectdetail));
      }
    }
    if(error==true){
      return false;
    }
    return true;
  }
}
