
import 'package:flutter/material.dart';

class Loading extends StatelessWidget{
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: 1000,
        width: 1000,
        child: CircularProgressIndicator(
          strokeWidth: 5,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation(Colors.white),
        )
    );
  }
}
class Login extends StatelessWidget{
  Widget build(BuildContext context) {
    return Container(
        //decoration: Cool Logo by Manuel Mitterrutzner
        alignment: Alignment.center,
        height: 1000,
        width: 1000,
        child: CircularProgressIndicator(
          strokeWidth: 5,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
    );
  }
}
class LoadingBar extends StatelessWidget{
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        height: 50,
        width: 50,
        child: CircularProgressIndicator(
          strokeWidth: 5,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation(Colors.white),
        )
    );
  }
}
class NoConnection extends StatelessWidget{
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
     Container(
         alignment: Alignment.center,
         height: 500,
         width: 1000,
         child: Text(
          'No Connection'
        )
    )
    ]
    );
  }
}