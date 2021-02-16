import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Profile {

  Widget build(BuildContext context) {
    return DrawProfile();
  }
}
class DrawProfile extends StatefulWidget{
  @override
  DrawProfileState createState() => DrawProfileState();
}
class DrawProfileState extends State<DrawProfile>{
  static bool firstaccess = true;
  Future<void> refresh() async{
    bool success =await Data().updateProfile();
   firstaccess = firstaccess==true?success:false;
    return;
  }
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
  Widget profilePicture(String url, String code){
    ImageCache().clear();
    if(code!=null){
      url += code;
      return Container(
        width: 250,
        height: 300,
        padding: EdgeInsets.all(20),
        child: CachedNetworkImage(
          imageUrl: url,
          httpHeaders: headers,
          placeholder: (context, url){
            return Loading();
          },
          imageBuilder: (context, imageProvider){
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.fitHeight,
                ),
              ),
            );
          }
        ),
      );
    } else {
      return Container();
    }
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
            if(snapshot.data==true){
              String data = Data.profile;
              String roleName = jsonDecode(data)['roleName'];
              String name = jsonDecode(data)['name'];
              String email = jsonDecode(data)['email'] ?? 'empty';
              String picture = jsonDecode(data)['picture'];
              String pictureUrl = Data.link + '/v2/api/profile/picture&pictureUrl=';
              cookie = Session().getCookie();
              headers = {'Cookie': cookie};
                  return ListView(
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
                  );
            }
            else if (snapshot.data == null) {
              return Loading();
            }
            else {
              return NoConnection();
            }
          }
      )
    );

  }
}