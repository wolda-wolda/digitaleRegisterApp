import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';

class Profile {
  static bool firstaccess = true;
  Future<bool> update() async {
    if (firstaccess) {
      if (await Data().updateProfile() == false) {
        if (await Data().loadProfile() == false) {
          print('Error');
          return false;
        }
      }
      firstaccess = false;
    }
    return true;
  }
  Widget profilePicture(String url, String code) {
    if(code!=null){
      url += code;
      return Container(
        width: 250,
        height: 250,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(url, headers: headers),
            fit: BoxFit.fitHeight,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: update(),
    builder: (context, AsyncSnapshot<bool> snapshot) {
    if(snapshot.data==true){
            String data = Data.profile;
            String roleName = jsonDecode(data)['roleName'];
            String name = jsonDecode(data)['name'];
            String email = jsonDecode(data)['email'] ?? 'empty';
            String picture = jsonDecode(data)['picture'];
            String pictureUrl = Data.link + '/v2/api/profile/picture&pictureUrl=';
            cookie = Session().getCookie();
            headers = {'Cookie': cookie};
            return RefreshIndicator(
            child: ListView(
              children: <Widget>[
                profilePicture(pictureUrl,picture),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text(name),
                ),
                ListTile(
                  leading: Icon(Icons.school),
                  title: Text(roleName),
                ),
                ListTile(
                  leading: Icon(Icons.alternate_email),
                  title: email != 'empty'
                      ? Text(email)
                      : Text('Email Adresse nicht verfügbar',
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic)),
                ),
              ],
            ),
              onRefresh: (){
                return Data().updateProfile();
              }
            );
  }
    else if (snapshot.data == null) {
      return Loading();
    }
    else {
      return NoConnection();
    }
    }
    );
  }
}