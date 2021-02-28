import 'dart:convert';
import 'package:digitales_register_app/Data/Load&Store.dart';
import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/digReg/PopUpMenu.dart';
import 'package:digitales_register_app/digReg/homePage.dart';
import 'package:digitales_register_app/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:digitales_register_app/digReg/settings.dart';
import 'package:provider/provider.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'SizeConfig.dart';
import 'package:digitales_register_app/digReg/usefulWidgets.dart';
import 'package:async/async.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _passwordVisible = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final linkController = TextEditingController();
  final titleController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> loginExists(
      String username, String password, String link) async {
    print(link);
    String ret = await Session().login(link + '/v2/api/auth/login', {
      "username": username,
      "password": password,
    });
    if (ret == 'e') {
      return false;
    }
    if (jsonDecode(ret)['error'] == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> login(BuildContext context) async {
    String ret =
        await Session().login(Data.currentlink + '/v2/api/auth/login', {
      "username": Data.currentuser,
      "password": Data.currentpassword,
    });
    if (ret == 'e') {
      SizedBox.shrink();
    }
    if (jsonDecode(ret)['error'] == null) {
      Data().initFirstaccess();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          (route) => false);
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          content: Text(jsonDecode(ret)['message'])));
    }
  }

  static bool firstlogin = true;
  load(_themeChanger, BuildContext context) async {
    return this._memoizer.runOnce(() async {
      await Data().loadUser();
      await Data().loadTheme(_themeChanger);
      await Data().getAutoLogin();
      if (firstlogin == true) {
        if (Data.autologin != 'e') {
          Data().setUser(Data.autologin);
          await login(context);
        }
        firstlogin = false;
      }
      return true;
    });
  }

  Widget leftBackground() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.green),
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              " Bearbeiten",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget rightBackground() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.red),
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              "Löschen ",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger =
        Provider.of<ThemeChanger>(context, listen: false);
    return FutureBuilder(
        future: load(_themeChanger, context),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            List<String> userlist = Data.user.keys.toList();
            SizeConfig().init(context);
            return Scaffold(
              key: scaffoldKey,
              body: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal * 90,
                          top: SizeConfig.blockSizeVertical * 5),
                      child: PopupMenuButton<String>(
                        onSelected: choiceAction,
                        itemBuilder: (BuildContext choice) {
                          return Constants.choices.map((String choice) {
                            if (choice == Constants.Setting) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.settings_applications,
                                      color: Colors.grey,
                                    ),
                                    Text(choice),
                                  ],
                                ),
                              );
                            } else if (choice == Constants.Exit) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.exit_to_app,
                                      color: Colors.grey,
                                    ),
                                    Text(choice),
                                  ],
                                ),
                              );
                            }
                          }).toList();
                        },
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.only(left: 40, right: 40, bottom: 25),
                        child: Column(children: <Widget>[
                          Text('Willkommen im digitalen Register',
                              style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: SizeConfig.safeBlockVertical * 4.5,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 40,
                          ),
                          Column(children: <Widget>[
                            Data.user.isNotEmpty
                                ? Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: Data.user.length,
                                      itemBuilder: (context, index) {
                                        String userkey=userlist[index];
                                        return Dismissible(
                                            background: leftBackground(),
                                            secondaryBackground:
                                                rightBackground(),
                                            confirmDismiss:
                                                // ignore: missing_return
                                                ((DismissDirection direction) {
                                              if (direction ==
                                                  DismissDirection.startToEnd) {
                                                editUser(context, userkey)
                                                    .then((context) {
                                                  setState(() {});
                                                });
                                              } else if (direction ==
                                                  DismissDirection.endToStart) {
                                                return showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return delete();
                                                    });
                                              }
                                            }),
                                            key: UniqueKey(),
                                            onDismissed: ((direction) {
                                              setState((){Data().removeUser(userkey);});
                                            }),
                                            child: ListTile(
                                                // TODO: ListTile borderradius isch pan swipen olbm no kantig
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                onLongPress: () {
                                                  editUser(context, userkey)
                                                      .then((context) {
                                                    setState(() {});
                                                  });
                                                },
                                                onTap: () async {
                                                  Data().setUser(userkey);
                                                  return login(context);
                                                },
                                                trailing: userkey==Data.autologin?Icon(LineAwesomeIcons.check):SizedBox.shrink(),
                                                leading: Icon(
                                                  LineAwesomeIcons.user,
                                                  size: 35,
                                                ),
                                                title: Text(
                                                    Data.user[userkey].title),
                                                subtitle: Text(Data
                                                    .user[userkey].username)));
                                      },
                                    ),
                                  )
                                : SizedBox.shrink(),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              height: 40,
                              width: 80,
                              child: RaisedButton(
                                onPressed: () {
                                  editUser(context, 'e').then((context) {
                                    setState(() {});
                                  });
                                },
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                                child: Icon(LineAwesomeIcons.plus_circle),
                                color: _themeChanger.getColor(),
                              ),
                            ),
                          ])
                        ])),
                  ],
                ),
              ),
            );
          }
          return Login();
        });
  }

  void choiceAction(String choice) {
    if (choice == Constants.Setting) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Settings();
      }));
    } else if (choice == Constants.Exit) {
      SystemNavigator.pop();
      return;
    }
  }

  Widget delete() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: const Text("Entfernen bestätigen"),
      content: const Text(
          "Sind Sie sicher, dass Sie diesen Benutzer Löschen möchten"),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Abbrechen"),
        ),
        FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Löschen")),
      ],
    );
  }

  bool autologin = true;
  editUser(context, String userkey) {
    if (userkey=='e') {
      titleController.clear();
      linkController.clear();
      passwordController.clear();
      usernameController.clear();
      autologin = false;
    } else {
      titleController..text = Data.user[userkey].title;
      linkController..text = Data.user[userkey].link;
      usernameController..text = Data.user[userkey].username;
      passwordController..text = Data.user[userkey].password;
      autologin = Data.autologin == userkey ? true : false;
    }

    ThemeChanger _themeChanger =
        Provider.of<ThemeChanger>(context, listen: false);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              content: Container(
                  height: 390,
                  child: Column(children: <Widget>[
                    TextFormField(
                      controller: titleController,
                      cursorColor: _themeChanger.getColor(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(LineAwesomeIcons.info_circle),
                        labelText: 'Titel',
                        hintText: 'Titel (Beliebig)',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    Divider(
                      height: 30,
                      endIndent: 100,
                      indent: 100,
                      thickness: 2,
                      color: _themeChanger.getColor(),
                    ),
                    TextField(
                      controller: linkController,
                      cursorColor: _themeChanger.getColor(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(LineAwesomeIcons.link),
                        labelText: 'Link',
                        hintText: 'Link für das Register',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    Divider(
                      height: 30,
                      endIndent: 100,
                      indent: 100,
                      thickness: 2,
                      color: _themeChanger.getColor(),
                    ),
                    TextField(
                      controller: usernameController,
                      cursorColor: _themeChanger.getColor(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(LineAwesomeIcons.user),
                        labelText: 'Benutzername',
                        hintText: 'Benutzername zum Register',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    Divider(
                      height: 30,
                      endIndent: 100,
                      indent: 100,
                      thickness: 2,
                      color: _themeChanger.getColor(),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: _passwordVisible,
                      cursorColor: _themeChanger.getColor(),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(LineAwesomeIcons.lock),
                          labelText: 'Passwort',
                          hintText: 'Passwort eingeben',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          )),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        createUser(userkey);
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(children: <Widget>[
                      Switch(
                          value: autologin,
                          onChanged: (bool state) {
                            setState(() {
                              autologin = !autologin;
                            });
                          }),
                      Spacer(),
                      Container(
                        height: 40,
                        width: 80,
                        child: RaisedButton(
                          onPressed: () async {
                            createUser(userkey);
                          },
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          child: Icon(LineAwesomeIcons.check_circle),
                          color: _themeChanger.getColor(),
                        ),
                      )
                    ])
                  ])));
        });
      },
    );
  }

  void createUser(String userkey) async{
    bool exists = await loginExists(
        usernameController.text.trim(),
        passwordController.text.trim(),
        Data().getLink(linkController.text.trim()));
    if (exists == true &&
        titleController.text.trim() != null) {
      await Data().setCurrentUser(
          userkey,
          usernameController.text.trim(),
          passwordController.text.trim(),
          titleController.text.trim(),
          Data().getLink(linkController.text.trim()));
      await Data().setAutoLogin(
          userkey, autologin);
      Navigator.pop(context, false);
    } else {
      print('Bitte überprüfen Sie Ihre Anmeldedaten');
    }
  }
}
