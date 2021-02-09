
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';

class Subjects {
  void showSub(BuildContext context, Grades data) {
    showDialog(
        context: context,
        builder: (context) {
          return PopUpDialog(data);
        });
  }

  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: Data.items.length,
      itemBuilder: (context, index1) {
        return ExpansionTileCard(
            borderRadius: BorderRadius.circular(10),
            title: Text(Data.items[index1].name.toString(),
                style: TextStyle(fontWeight: FontWeight.bold)),
            children: <Widget>[
              Divider(
                thickness: 1.0,
                height: 1.0,
              ),
                    Column(
                        children: [

                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: Data.items[index1]
                                  .grades
                                  .observations
                                  .length,
                              itemBuilder: (context, index2) {
                                return ListTile(
                                    title: Text(Data.items[index1]
                                        .grades
                                        .observations[index2]
                                        .type
                                        .toString()));
                              }),
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount:
                              Data.items[index1].grades.grades.length,
                              itemBuilder: (context, index2) {
                                return ListTile(
                                  title: Text(Data.items[index1]
                                      .grades
                                      .grades[index2]
                                      .type
                                      .toString() +
                                      ': ' +
                                      Data.items[index1]
                                          .grades
                                          .grades[index2]
                                          .grade
                                          .toString() +
                                      ' - ' +
                                      Data.items[index1]
                                          .grades
                                          .grades[index2]
                                          .weight
                                          .toString() +
                                      '%'));
                              })
                        ]

                      )
                     ]
                  );
               }
           );
        }
      }

class PopUpDialog extends StatelessWidget {
  final Grades data;
  PopUpDialog(this.data);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(data.type + ": " + data.grade),
      content: SingleChildScrollView(
        child: Text(data.description),
      ),
    );
  }
}
