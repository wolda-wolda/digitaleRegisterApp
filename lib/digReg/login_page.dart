import 'dart:convert';

import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/digReg/PopUpMenu.dart';
import 'package:digitales_register_app/digReg/homePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:digitales_register_app/digReg/settings.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Digitales Register"),
        actions: <Widget>[
          PopupMenuButton<String>(
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
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(50),
                child: Column(children: [
                  TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                      textInputAction: TextInputAction.next),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _isHidden,
                    decoration: InputDecoration(
                        labelText: 'Passwort',
                        suffix: InkWell(
                          onTap: _togglePasswordView,
                          child: Icon(
                            _isHidden ? Icons.visibility : Icons.visibility_off,
                          ),
                        )),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (passwordController) {
                      login(context);
                    },
                  )
                ])),
            RaisedButton(
              onPressed: () {
                login(context);
              },
              child: Text('Login'),
            ),
            /*RaisedButton(
              onPressed: () {
                Session()
                    .get(
                        'https://fallmerayer.digitalesregister.it/v2/api/profile/get')
                    .then((value) => {});
              },
              child: Text('Get Profile Info'),
            ),
            RaisedButton(
              onPressed: () {
                Session().post(
                    'https://fallmerayer.digitalesregister.it/v2/api/student/dashboard/dashboard',
                    {'viewFuture': 'true'}).then((value) => {});
              },
              child: Text('Get Dashboard'),
            ),*/
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
