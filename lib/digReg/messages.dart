import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';

class Messages {


  Widget build(BuildContext context) {
    return DrawMessages();
  }
}
class DrawMessages extends StatefulWidget{
  @override
  DrawMessagesState createState() => DrawMessagesState();
}
class DrawMessagesState extends State<DrawMessages>{
  static bool firstaccess = true;
  Future<bool> update() async {
    if (firstaccess) {
      if (await Data().updateMessages() == false &&
          await Data().loadMessages() == false) {
        print('Error');
        return false;
      }
      firstaccess = false;
    }
    return true;
  }
  void showMessage(BuildContext context, Mess data) {
    showDialog(
        context: context,
        builder: (context) {
          return PopUpDialog(data);
        });
  }

  List<Mess> items = List<Mess>();
  bool get = true;
  void refresh() async{
    bool success =await Data().updateMessages();
    firstaccess = firstaccess==true?!success:false;
    return;
  }
  @override
  Widget build(BuildContext context){
    return RefreshIndicator(
      onRefresh: () async {
        await refresh();
        setState((){});
        return Future.value(true);
      },
    child: FutureBuilder(
        future: update(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if(snapshot.data==true){
            String data = Data.messages;
            if (get == true) {
              for (var i in jsonDecode(data)) {
                items.add(Mess.fromJson(i));
                get = false;
              }
            }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        onTap: () => showMessage(context, items[index]),
                        title: Text(items[index].subject),
                        subtitle: Text(items[index].date));
                  },
                );
          }
          else if (snapshot.data == null) {
            return Loading();
          }
          else {
            return NoConnection();
          }
        }
    ),
    );
  }
}

class Mess {
  final int id;
  final String subject;
  final String text;
  final String date;

  Mess({this.id, this.subject, this.text, this.date});

  factory Mess.fromJson(Map<String, dynamic> json) {
    String text = '';
    for (var i in Txt.fromJson(jsonDecode(json['text'])).ops) {
      text = text + i['insert'].toString();
    }
    return Mess(
        id: json['id'],
        subject: json['subject'],
        text: text,
        date: Date.format(json['timeSent']).date);
  }
}

class Txt {
  final List<dynamic> ops;
  Txt({this.ops});

  factory Txt.fromJson(Map<String, dynamic> json) => Txt(ops: json['ops']);
}

class Date {
  final String date;
  Date(this.date);

  factory Date.format(String enDate) {
    String day;
    String month;
    String year;
    String raw;

    raw = enDate.split(' ')[0];
    day = raw.split('-')[2];
    month = raw.split('-')[1];
    year = raw.split('-')[0];

    return Date(day + '.' + month + '.' + year);
  }
}

class PopUpDialog extends StatelessWidget {
  final Mess data;

  PopUpDialog(this.data);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(data.subject),
      content: SingleChildScrollView(
          scrollDirection: Axis.vertical, child: Text(data.text)),
    );
  }
}
