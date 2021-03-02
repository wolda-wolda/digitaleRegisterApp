import 'dart:convert';
import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:settings_ui/settings_ui.dart';

class DrawProfile extends StatefulWidget{
  @override
  DrawProfileState createState() => DrawProfileState();
}
class DrawProfileState extends State<DrawProfile>{
  Future<void> refresh() async{
    bool success =await Data().updateProfile();
   Data.firstaccess["profile"] = Data.firstaccess["profile"]==true?!success:false;
    return;
  }
  static bool notificationsEnabled;
  Future<bool> changeNotification() async{
    if((await Session().post(Data.currentlink +'/v2/api/profile/updateNotificationSettings', {'notificationsEnabled': notificationsEnabled}))=='e'){
      return false;
    }
    else{
      return true;
    }
  }
  Widget notifications(bool notificationsEnabled) {
    if (notificationsEnabled == true)
      return Icon(Icons.notifications_active);
    else
      return Icon(Icons.notifications);
  }


  Future<bool> update() async {
    if (Data.firstaccess["profile"]) {
      if (await Data().updateProfile() == false) {
        if (await Data().loadProfile() == false) {
          print('Error');
          return false;
        }
      }
      Data.firstaccess["profile"] = false;
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

  final snackBar =  GlobalKey<ScaffoldState>();
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
              if (Data.firstaccess["notifications"]==true) {
                notificationsEnabled =
                jsonDecode(data)['notificationsEnabled'];
                Data.firstaccess["notifications"]=false;
              }
              String roleName = jsonDecode(data)['roleName'];
              String name = jsonDecode(data)['name'];
              String email = jsonDecode(data)['email'] ?? 'empty';
              String picture = jsonDecode(data)['picture'];
              String pictureUrl = Data.currentlink + '/v2/api/profile/picture&pictureUrl=';
              cookie = Session().getCookie();
              headers = {'Cookie': cookie};
              return Scaffold(
                  key: snackBar,
                  body: ListView(
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
                      email!='empty'?
                      SettingsTile.switchTile(
                          leading: notifications(notificationsEnabled),
                          title: 'Email-Benachrichtigungen',
                          onToggle: (value) async{
                            notificationsEnabled = value;
                            if(await changeNotification()==false) {
                              notificationsEnabled = !value;
                              snackBar.currentState.showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),content: Text('Keine Netzwerkverbindung')));
                            }
                            setState((){});
                            },
                          switchValue: notificationsEnabled
                      ):
                          SizedBox.shrink(),
                    ],
                  ));
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