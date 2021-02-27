import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Messages {
  Widget build(BuildContext context) {
    return DrawMessages();
  }
}

class DrawMessages extends StatefulWidget {
  @override
  DrawMessagesState createState() => DrawMessagesState();
}

class DrawMessagesState extends State<DrawMessages> {
  Future<bool> update() async {
    if (Data.firstaccess["messages"]) {
      if (await Data().updateMessages() == false &&
          await Data().loadMessages() == false) {
        print('Error');
        return false;
      }
      Data.firstaccess["messages"] = false;
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
  void refresh() async {
    bool success = await Data().updateMessages();
    Data.firstaccess["messages"] = Data.firstaccess["messages"] == true ? !success : false;
    return;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await refresh();
        setState(() {});
        return Future.value(true);
      },
      child: FutureBuilder(
          future: update(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == true) {
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
                  return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                              5)),
                      child: ListTile(
                      onTap: () => showMessage(context, items[index]),
                      title: Text(items[index].subject),
                      subtitle: Text(items[index].date)));
                },
              );
            } else if (snapshot.data == null) {
              return Loading();
            } else {
              return NoConnection();
            }
          }),
    );
  }
}

class Mess {
  final int id;
  final String subject;
  final String text;
  final String date;
  final List<Submissions> sub;

  Mess({this.id, this.subject, this.text, this.date, this.sub});
  factory Mess.fromJson(Map<String, dynamic> json) {
    String text = '';
    for (var i in Txt.fromJson(jsonDecode(json['text'])).ops) {
      text = text + i['insert'].toString();
    }
    List<Submissions> temp = List<Submissions>();
    for (var i in json['submissions']) {
      temp.add(Submissions.fromJson(i));
    }
    return Mess(
        id: json['id'],
        subject: json['subject'],
        text: text,
        date: Date.format(json['timeSent']).date,
        sub: temp);
  }
}

class Submissions {
  final String name;
  final bool isDownloadable;
  final int id;
  final String file;

  Submissions({this.name, this.isDownloadable, this.id, this.file});

  factory Submissions.fromJson(Map<String, dynamic> json) {
    return Submissions(
        name: json['originalName'],
        isDownloadable: json['isDownloadable'],
        id: json['id'],
        file: json['file']);
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

  void openFile(int index) {
    Session().downloadFile(
        'https://fallmerayer.digitalesregister.it/v2/api/message/messageSubmissionDownloadEntry?submissionId=' +
            data.sub[index].id.toString() +
            '&messageId=' +
            data.id.toString(),
        data.sub[index].file);
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = List<String>();
    for (var i in data.sub) {
      items.add(i.name);
    }
    return AlertDialog(
        title: Text(data.subject),
        content: Container(
            width: 300,
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Text(data.text),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            leading: Icon(LineAwesomeIcons.file),
                            title: Text(items[index]),
                            onTap: () => openFile(index));
                      })
                ]))));
  }
}
