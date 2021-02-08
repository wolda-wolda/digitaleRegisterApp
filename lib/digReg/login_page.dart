import 'dart:convert';

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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  bool _isHidden = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final scaffoldKey =  GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login(BuildContext context) async {
    String ret = await Session()
        .login('https://fallmerayer.digitalesregister.it/v2/api/auth/login', {
      "username": usernameController.text.trim(),
      "password": passwordController.text.trim()
    });
    if (jsonDecode(ret)['error'] == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          (route) => false);
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),content: Text(jsonDecode(ret)['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        child: Column(
          children: <Widget> [
            Container(
              margin: EdgeInsets.only(left: 350, top: 30),
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
            SizedBox(
              height: 20,
            ),
            Container(
                padding: EdgeInsets.only(left: 40, right: 40, bottom: 25),
                child: Column(children: <Widget> [
                  Text('Willkommen im digitalen Register', style: TextStyle(fontFamily: 'OpenSans', fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 50,
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
                      hintText: 'Benutzername für das Register',
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (usernameController) {
                      login(context);
                    },
                  ),
                  Divider(
                    height: 50,
                    endIndent: 100,
                    indent: 100,
                    thickness: 2,
                    color: _themeChanger.getColor(),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: _isHidden,
                    cursorColor: _themeChanger.getColor(),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(LineAwesomeIcons.lock),
                        labelText: 'Passwort',
                        hintText: 'Passwort eingeben',
                        suffix: InkWell(
                          onTap: _togglePasswordView,
                          child: Icon(
                            _isHidden ? Icons.visibility : Icons.visibility_off,
                          ),
                        )),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (passwordController) {
                      login(context);
                    },
                  )
                ])),
            Container(
              height: 50,
              width: 150,
              child: RaisedButton(
                onPressed: () {
                  login(context);
                },
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                child: Text('Login'),
                color: _themeChanger.getColor(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
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
}
