import 'package:digitales_register_app/API/API.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class User{
  final String username;
  final String password;
  final String title;
  final String link;
  User(this.username,this.password,this.title,this.link);
  Map toJson() =>
      {
        "username": username,
        "password": password,
        "title": title,
        "link": link,
      };
  factory User.decode(Map<String, dynamic> json){
    return User(
      json["username"],
      json["password"],
      json["title"],
      json["link"],
    );
  }
}

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
  static Map<String,bool> firstaccess={};
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
  static String currentlink = 'https://fallmerayer.digitalesregister.it';
  static Map<String,dynamic> user = {};
  static String currentuser;
  static String currentpassword;
  static String currenttitle;
  static String autologin='e';
  static String currentid;

  void initFirstaccess(){
    firstaccess["absences"]=true;
    firstaccess["calendar"]=true;
    firstaccess["dashboard1"]=true;
    firstaccess["dashboard2"]=true;
    firstaccess["messages"]=true;
    firstaccess["profile"]=true;
    firstaccess["subjects"]=true;
    firstaccess["notifications"]=true;
  }
  Future<String> getAutoLogin()async{
    final preferences = await SharedPreferences.getInstance();
    if(preferences.getString("Autologin")==null){
      autologin ='e';
    }else{
      autologin = preferences.getString("Autologin");
    }
    return autologin;
  }
  Future<bool> setAutoLogin(String userkey,bool toggle)async{
    final preferences = await SharedPreferences.getInstance();
    if(toggle && userkey != autologin){
      autologin=userkey;
      preferences.setString("Autologin",userkey);
    }else if(!toggle && userkey==autologin){
      autologin = 'e';
      preferences.remove("Autologin");
    }else if(userkey=='e'&& toggle){
      autologin = currentid;
      preferences.setString("Autologin",currentid);
    }
    return true;
  }
  Future<bool> storeTheme(Color color,bool theme) async{
    final preferences = await SharedPreferences.getInstance();
    preferences.setInt("Color", color.value);
    preferences.setBool("Theme",theme);
    return true;
  }
  Future<bool> loadTheme(_themeChanger) async{
    final preferences = await SharedPreferences.getInstance();
    if(preferences.getInt("Color")!=null){
      _themeChanger.setColor(Color(preferences.getInt('Color')));
    }
    if(preferences.getBool('Theme')!=null){
      _themeChanger.setBool(preferences.getBool('Theme'));
    }
    return true;
  }
  Future<bool> loadUser() async{
    final preferences = await SharedPreferences.getInstance();
    String jsonUser = preferences.getString("User");
    if(jsonUser!=null) {
      Map<String,dynamic> usermap = jsonDecode(jsonUser);
      for (var i in usermap.keys.toList()) {
        user[i]=(User.decode(usermap[i]));
      }
    }else{
      return false;
    }
    return true;
  }
   Future<bool> removeUser(String userkey) async{
    String username = user[userkey].username;
    final preferences = await SharedPreferences.getInstance();
    await setAutoLogin(userkey,false);
    List<String> userlist = user.keys.toList();
    user[userkey]= user[userlist[userlist.length-1]];
    user.remove(userlist[userlist.length-1]);
      String jsonUser = jsonEncode(user);
      preferences.setString("User",jsonUser);
    preferences.remove(username + 'profile');
    preferences.remove(username + 'absences');
    preferences.remove(username + 'unread');
    preferences.remove(username + 'dashboard');
    preferences.remove(username + 'calendar');
    for(var i=0;i<100;i++){
      preferences.remove(username + 'calendardetail' + i.toString());
    }
    String temp;
    if(preferences.containsKey(username+'subjects')){
      temp = preferences.getString(username+'subjects');
      for(var i=0;i<jsonDecode(temp).length;i++){
        preferences.remove(username + 'subjectdetail' + i.toString());
      }
    }
    preferences.remove(username + 'subjects');

   return true;
  }
  void setUser(String userkey) {
    currentuser=user[userkey].username;
    currentpassword=user[userkey].password;
    currentlink=user[userkey].link;
    currentid=userkey;
  }
  String getLink(String link){
    if(link.contains('https://') && link.contains('.digitalesregister.it')){
      link=link;
    }else if(link.contains('https://') && !link.contains('.digitalesregister.it')){
      link = link+ '.digitalesregister.it';
    }else{
      link = 'https://' +link+'.digitalesregister.it';
    }
    return link;
  }
  Future<bool> setCurrentUser(String userkey, String username, String password, String title, String link) async{
    currentuser=username;
    currentpassword=password;
    currenttitle= title;
    currentlink=link;

    final preferences = await SharedPreferences.getInstance();
    if(userkey=='e') {
      if (user.isNotEmpty) {
        var newuser = (User(username, password, title, link));
        List<String> userkeys = user.keys.toList();
        String newid = (int.parse(userkeys[userkeys.length - 1]) + 1).toString();
        user[newid] =
            newuser;
        currentid=newid;
      } else {
        user["0"] = (User(username, password, title, link));
        currentid='0';
      }
    }else{
      user[userkey] = (User(username, password, title, link));
      currentid=userkey;
    }
    String jsonUser = jsonEncode(user);
    preferences.setString("User",jsonUser);
    return true;
  }
  Future<bool> updateProfile() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().get(currentlink + '/v2/api/profile/get');
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString(currentuser + 'profile', cache);
      await Data().loadProfile();
      return true;
    }
  }
  Future<bool> updateAbsences() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().get(currentlink + '/v2/api/student/dashboard/absences');
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString(currentuser + 'absences', cache);
      await Data().loadAbsences();
      return true;
    }
  }
  Future<bool> updateUnread() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().get(currentlink + '/v2/api/notification/unread');
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString(currentuser + 'unread', cache);
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
          .post(currentlink + '/v2/api/calendar/student', {'startDate': monday});
      if (cache == 'e') {
        return false;
      } else {
        preferences.setString(currentuser + 'calendardetail' + i.toString(), cache);
        calendar[i] = cache;
      }
    }
    return true;
  }

  Future<bool> updateDashboard() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().post(
        currentlink + '/v2/api/student/dashboard/dashboard', {'viewFuture': true});
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString(currentuser + 'dashboard', cache);
      await Data().loadDashboard();
      return true;
    }
  }

  Future<bool> updateSubjects() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().get(currentlink + '/v2/api/student/all_subjects');
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString(currentuser + 'subjects', cache);
      subjectitems2.clear();
      subjects = preferences.getString(currentuser + 'subjects');
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
    if (preferences.getString(currentuser + 'subjects') == null) {
      return false;
    }
    subjects = preferences.getString(currentuser + 'subjects');
    for (var i = from; i <= to; i++ ) {
      id = subjectitems[i].id;
      studentId = subjectitems[i].studentId;
      subjectdetail = await Session().post(
          currentlink + '/v2/api/student/subject_detail',
          {'subjectId': id, 'studentId': studentId});
      if(subjectdetail=='e'){
        return false;
      }
      else {
        preferences.setString(currentuser + "subjectdetail" + i.toString(), subjectdetail);
        subjectitems[i].content = Content.fromJson(jsonDecode(subjectdetail));
      }
    }
    return true;
  }

  Future<bool> updateMessages() async {
    final preferences = await SharedPreferences.getInstance();
    cache = await Session().post(
        currentlink + '/v2/api/message/getMyMessages', {'filterByLabelName': ''});
    if (cache == 'e') {
      return false;
    } else {
      preferences.setString(currentuser + 'messages', cache);
      await Data().loadMessages();
      return true;
    }
  }
  Future<bool> loadProfile() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(currentuser + 'profile') == null) {
      return false;
    }
    profile = preferences.getString(currentuser + 'profile');
    return true;
  }

  Future<bool> loadAbsences() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(currentuser + 'absences') == null) {
      return false;
    }
    absences = preferences.getString(currentuser + 'absences');
    return true;
  }

  Future<bool> loadCalendar(var from, var to) async {
    final preferences = await SharedPreferences.getInstance();
    for (var i = from; i <= to; i++) {
      if (preferences.containsKey(currentuser + 'calendardetail' + i.toString()) &&
          preferences.getString(currentuser + 'calendardetail' + i.toString()) != null) {
        calendardetail = preferences.getString(currentuser + 'calendardetail' + i.toString());
        calendar[i] = calendardetail;
      } else {
        return false;
      }
    }
    return true;
  }

  Future<bool> loadDashboard() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(currentuser + 'dashboard') == null) {
      return false;
    }
    dashboard = preferences.getString(currentuser + 'dashboard');
    return true;
  }

  Future<bool> loadMessages() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(currentuser + 'messages') == null) {
      return false;
    }
    messages = preferences.getString(currentuser + 'messages');
    return true;
  }
  Future<bool> loadUnread() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(currentuser + 'unread') == null) {
      return false;
    }
    unread = preferences.getString(currentuser + 'unread');
    return true;
  }

  Future<bool> loadSubjects() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(currentuser + 'subjects') == null) {
      return false;
    }
    subjects = preferences.getString(currentuser + 'subjects');
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
      if(preferences.containsKey("subjectdetail" + i.toString())==false || preferences.getString(currentuser + "subjectdetail" + i.toString())==null){
        error=true;
      }
      else {
        subjectdetail = preferences.getString(currentuser + "subjectdetail" + i.toString());
        subjectitems2[i].content = Content.fromJson(jsonDecode(subjectdetail));
      }
    }
    if(error==true){
      return false;
    }
    return true;
  }
}
