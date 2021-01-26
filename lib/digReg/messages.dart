import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Messages {
  Future<String> getData() async {
    String data = await Session().post(
        'https://fallmerayer.digitalesregister.it/v2/api/message/getMyMessages',
        {'filterByLabelName': ''});
    return data;
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

  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getData(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            if (get == true) {
              for (var i in jsonDecode(snapshot.data)) {
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
                  subtitle: Text(items[index].date)
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

class Mess {
  final int id;
  final String subject;
  final String text;
  final String date;

  Mess({this.id, this.subject, this.text, this.date});

  factory Mess.fromJson(Map<String, dynamic> json) => Mess(
      id: json['id'],
      subject: json['subject'],
      text: Txt.fromJson(jsonDecode(json['text'])).ops[0]['insert'],
      date: Date.format(json['timeSent']).date
  );
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
