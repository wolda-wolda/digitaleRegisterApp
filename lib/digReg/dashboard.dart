import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';

class Dashboard {
  final ValueChanged update;

  Dashboard({this.update});

  Widget build(BuildContext context) {
    return DrawDashboard();
  }
}

class DrawDashboard extends StatefulWidget {
  final ValueChanged<int> update;

  DrawDashboard({this.update});

  @override
  DrawDashboardState createState() => DrawDashboardState();
}

class DrawDashboardState extends State<DrawDashboard> {
  ScrollController _scrollController;

  Future<bool> update() async {
    if (Data.firstaccess["dashboard1"]) {
      if (await Data().updateDashboard() == false) {
        if (await Data().loadDashboard() == false) {
          print('Error');
          return false;
        }
      }
      Data.firstaccess["dashboard1"] = false;
    }
    return true;
  }

  Future<bool> update2() async {
    if (Data.firstaccess["dashboard2"]) {
      if (await Data().updateUnread() == false) {
        if (await Data().loadUnread() == false) {
          print('Error');
          return false;
        }
      }
      Data.firstaccess["dashboard2"] = false;
    }
    return true;
  }

  Future<bool> load() async {
    if (await update2() && await update()) {
      return true;
    }
    return false;
  }

  var items = List<Dash>();
  bool get1 = true;
  bool get2 = true;
  List<Unread> list = List<Unread>();

  Future<void> refresh() async {
    bool success = await Data().updateDashboard();
    Data.firstaccess["dashboard1"] =
        Data.firstaccess["dashboard1"] == true ? !success : false;
    success = await Data().updateUnread();
    Data.firstaccess["dashboard2"] =
        Data.firstaccess["dashboard2"] == true ? !success : false;
    get1 = true;
    get2 = true;
    setState(() {
      _scrollController.jumpTo(list.length * 100.0);
    });
    return;
  }

  var reminderController = new TextEditingController();

  Future<void> safeReminder(String date, String text) async {
    var ret = await Session().post(
        Data.currentlink + '/v2/api/student/dashboard/save_reminder',
        {'date': date, 'text': text});
    print(ret);
    return;
  }

  Widget divider(ThemeChanger _themeChanger) {
    if (list.isEmpty) {
      return Container();
    }
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Icon(Icons.arrow_circle_up, color: _themeChanger.getColor())
    ]);
  }

  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);

    return RefreshIndicator(
      onRefresh: () async {
        await refresh();
        return Future.value(true);
      },
      child: FutureBuilder(
          future: load(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == true) {
              if (get1 == true) {
                items.clear();
                for (var i in jsonDecode(Data.dashboard)) {
                  items.add(Dash.fromJson(i));
                }
                get1 = false;
              }
              if (get2 == true) {
                list.clear();
                for (var i in jsonDecode(Data.unread)) {
                  list.add(Unread.fromJson(i));
                }
                get2 = false;
              }
              _scrollController = new ScrollController(
                  initialScrollOffset: list.length * 100.0);
              return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(children: [
                    unread(context),
                    divider(_themeChanger),
                    ListView.builder(
                      physics: ScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index1) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                              title: Text(
                                items[index1].date.toString(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.add),
                                    title: Text('Erinnerung hinzufügen'),
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            reminderController.clear();
                                            return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0))),
                                                content: Container(
                                                    height: 60,
                                                    child: TextFormField(
                                                      controller:
                                                          reminderController,
                                                      cursorColor: _themeChanger
                                                          .getColor(),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Erinnerung',
                                                        hintText:
                                                            'Erinnerung (z.B. Hausaufgabe)',
                                                      ),
                                                      textInputAction:
                                                          TextInputAction.done,
                                                      onFieldSubmitted:
                                                          (_) async {
                                                        DateTime date =
                                                            new DateFormat(
                                                                    'EEEE, d. MMM yyyy',
                                                                    'de_DE')
                                                                .parse(items[
                                                                        index1]
                                                                    .date);
                                                        await safeReminder(
                                                                DateFormat(
                                                                        'yyyy-MM-d')
                                                                    .format(
                                                                        date)
                                                                    .toString(),
                                                                reminderController
                                                                    .text)
                                                            .then((data) async {
                                                          await refresh()
                                                              .then((data) {
                                                            setState(() {});
                                                          });
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )));
                                          });
                                    },
                                  ),
                                  Divider(
                                    height: 20,
                                    endIndent: 150,
                                    indent: 150,
                                    thickness: 2,
                                    color: _themeChanger.getColor(),
                                  ),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: items[index1].items.length,
                                    itemBuilder: (context, index2) {
                                      return ListTile(
                                        title: title(
                                            context, items[index1], index2),
                                        trailing: title2(context, items[index1],
                                            index2, _themeChanger),
                                        subtitle: Text(items[index1]
                                            .items[index2]
                                            .subtitle
                                            .toString()),
                                      );
                                    },
                                  )
                                ],
                              )),
                        );
                      },
                    )
                  ]));
            } else if (snapshot.data == null) {
              return Loading();
            } else {
              return NoConnection();
            }
          }),
    );
  }

  Widget title(BuildContext context, Dash item, int index2) {
    if (item.items[index2].label != null)
      return Text(
        item.items[index2].title.toString(),
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      );
    return Text(
      item.items[index2].title.toString(),
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  // ignore: missing_return
  Widget title2(
      BuildContext context, Dash item, int index2, ThemeChanger _themeChanger) {
    if (item.items[index2].label != null) {
      return Container(
          height: 40,
          width: 130,
          child: Transform(
            transform: Matrix4.translationValues(22, 0.0, 0.0),
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: _themeChanger.getColor(),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    item.items[index2].label.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          ));
    } else {
      if (item.items[index2].deletable == true) {
        return GestureDetector(
          onTap: () async {
            await Session().post(
                Data.currentlink + '/v2/api/student/dashboard/delete_reminder',
                {'id': item.items[index2].id});
            item.items.removeAt(index2);
            await refresh().then((data) {
              setState(() {});
            });
          },
          child: Icon(Icons.delete),
        );
      }
    }
  }

  void unreadOption(int index) {
    Unread data = list[index];
    print(data.type);
    if (data.type == 'message') {
      markAsRead(index);
      widget.update(4);
    } else if (data.type == 'grade') {
      markAsRead(index);
      widget.update(3);
    }
  }

  Future<void> markAsRead(int index) {
    Session().post(
        'https://fallmerayer.digitalesregister.it/v2/api/notification/markAsRead',
        {'id': list[index].id});
    list.removeAt(index);
    // TODO: DATA removeUnread
  }

  Widget unread(BuildContext context) {
    if (list.isNotEmpty) {
      if(_scrollController.hasClients) {
        setState(() {
          _scrollController.jumpTo(list.length * 100.0);
        });
      }
      return ListView.builder(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index2) {
            return Dismissible(
                onDismissed: (direction) {
                  markAsRead(index2);
                },
                key: Key(list[index2].id.toString()),
                child: Container(
                  height: 100,
                  child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                          onTap: () {
                            unreadOption(index2);
                          },
                          title: Text(list[index2].title),
                          subtitle: Text(list[index2].timeSent))),
                ));
          });
    } else {
      return SizedBox.shrink();
    }
  }
}

class Dash {
  final String date;
  final List<Items> items;

  Dash({this.date, this.items});

  factory Dash.fromJson(Map<String, dynamic> json) {
    List<Items> temp = [];
    for (var i in json['items']) {
      temp.add(Items.fromJson(i));
    }
    return Dash(date: Date.format(json['date']).date, items: temp);
  }
}

class Items {
  final String title;
  final String subtitle;
  final String label;
  final bool checkable;
  final bool checked;
  final bool deletable;
  final bool warning;
  final String type;
  final int id;

  Items(
      {this.subtitle,
      this.title,
      this.label,
      this.checkable,
      this.checked,
      this.deletable,
      this.warning,
      this.type,
      this.id});

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
        subtitle: json['subtitle'],
        title: json['title'],
        label: json['label'],
        checkable: json['checkable'],
        checked: json['checked'],
        deletable: json['deleteable'],
        warning: json['warning'],
        type: json['type'],
        id: json['id']);
  }
}
