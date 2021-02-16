import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';


var currentindex=0;
class Calendar{
  final controller = PageController(initialPage: 50);
  Widget build(BuildContext context) {
    return PageView.builder(
        itemCount: 100,
        controller: controller,
        itemBuilder: (BuildContext context, int index) {
          print('index: ' + index.toString());
          currentindex=index;
         return DrawCalendar();
        }
    );
  }
}

class DrawCalendar extends StatefulWidget{
  @override
  DrawCalendarState createState() => DrawCalendarState();

}
class DrawCalendarState extends State<DrawCalendar>{
  static Map<int,bool> loaded={};
  static bool firsttime=true;
  void initload(){
    if(firsttime==true){
      for(var i=0;i<100;i++){
        loaded[i]=false;
      }
      firsttime=false;
    }
    return;
  }
  void refresh() async{
    loaded[currentindex]=  loaded[currentindex]==false?await Data().updateCalendar(currentindex,currentindex):true;
    return;
  }
  Future<bool> update() async {
    initload();
    print('loaded[currentindex]: ' + loaded[currentindex].toString());
    if(loaded[currentindex]==false || loaded[currentindex] ==null) {
      if (await Data().updateCalendar(currentindex, currentindex) == false) {
        if (await Data().loadCalendar(currentindex, currentindex) == false) {
          print('Error');
          return false;
        }
      }
      loaded[currentindex]=true;
    }
    return true;
  }
  void showLesson(BuildContext context, Lesson data) {
    showDialog(
        context: context,
        builder: (context) {
          return PopUpDialog(data);
        });
  }
  bool linked = false;

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
              if (snapshot.hasData && snapshot.data == true) {
                Data.calendaritems.clear();
                Data.week2 =
                (jsonDecode(Data.calendar[currentindex]).keys.toList());
                for (var i in Data.week2) {
                  Data.calendaritems.add(
                      Day.fromJson(
                          jsonDecode(Data.calendar[currentindex])[i]['1']['1']));
                }
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: Data.week2.length,
                  itemBuilder: (context, index1) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                            Date
                                .format(
                                jsonDecode(Data.calendar[currentindex]).keys
                                    .toList()[index1])
                                .date,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: Data.calendaritems[index1].list.length,
                          itemBuilder: (context, index2) {
                            return ListTile(
                              leading: Text(hour(
                                  Data.calendaritems[index1].list[index2])),
                              title: Text(
                                  Data.calendaritems[index1].list[index2]
                                      .subject,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              onTap: () =>
                                  showLesson(
                                      context, Data.calendaritems[index1]
                                      .list[index2]),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }
              else if (snapshot.hasData && snapshot.data == false) {
                return NoConnection();

              }
              return Loading();
            }
        )
    );
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

