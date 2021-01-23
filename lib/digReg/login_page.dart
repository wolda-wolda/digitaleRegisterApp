import 'package:digitales_register_app/API/API.dart';
import 'package:digitales_register_app/digReg/PopUpMenu.dart';
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

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    Session()
        .login('https://fallmerayer.digitalesregister.it/v2/api/auth/login', {
      "username": usernameController.text.trim(),
      "password": passwordController.text.trim()
    }).then((value) => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Digitales Register"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context){
              return Constants.choices.map((String choice){
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.settings),
                      Text(choice),
                    ],
                  ),
                );
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
                    decoration: InputDecoration(labelText: 'Passwort', suffix: InkWell(
                      onTap: _togglePasswordView,
                      child: Icon(_isHidden ? Icons.visibility : Icons.visibility_off,),
                    )),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (passwordController) {
                      login();
                    },
                  )
                ])),
            RaisedButton(
              onPressed: () {
                login();
              },
              child: Text('Login'),
            ),
            RaisedButton(
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
            ),
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
  void choiceAction(String choice){
    if(choice == Constants.Setting){
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Settings();
      }));
    }
  }
}
