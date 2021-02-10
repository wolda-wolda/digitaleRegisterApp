
import 'package:flutter/material.dart';

class Loading extends StatelessWidget{
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: 20,
        width: 20,
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
    return Container(
        alignment: Alignment.center,
        height: 1000,
        width: 1000,
        child: Text(
          'No Connection'
        )
    );
  }
}