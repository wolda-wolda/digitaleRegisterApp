import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Profile {
  Future<String> getData() async {
    String data = await Session().get('https://fallmerayer.digitalesregister.it/v2/api/profile/get');
    return data;
  }

  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getData(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            String pictureurl;
            String email;
            String roleName = jsonDecode(snapshot.data)['roleName'];
            String name = jsonDecode(snapshot.data)['name'];
            if( jsonDecode(snapshot.data)['email']!= null){
              email = jsonDecode(snapshot.data)['email'];
            }
            if( jsonDecode(snapshot.data)['picture']!=null ){
              pictureurl = 'https://fallmerayer.digitalesregister.it/v2/api/profile/picture&pictureUrl=' + jsonDecode(snapshot.data)['picture'];
            }


            Map<String, String> headers;
            cookie = Session().getCookie();
            headers = {'Cookie': cookie};
            return ListView(
              children: <Widget>[
                Container(
                  width: 250,
                  height: 250,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: pictureurl != null ? NetworkImage(pictureurl, headers: headers ) : AssetImage('assets/images/nopicture.jpg'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
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
                  title: email != null ? Text(email) : Text('Email Adresse nicht verfügbar', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ),
              ],
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

