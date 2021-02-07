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
            String roleName = jsonDecode(snapshot.data)['roleName'];
            String name = jsonDecode(snapshot.data)['name'];
            String email = jsonDecode(snapshot.data)['email'];
            String pictureurl = 'https://fallmerayer.digitalesregister.it/v2/api/profile/picture&pictureUrl=' + jsonDecode(snapshot.data)['picture'];
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
                      image: NetworkImage(pictureurl, headers: headers ),
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
                  title: Text(email),
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

