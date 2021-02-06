import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:digitales_register_app/API/API.dart';

class GetData{
  static String cookie;
  static String profile;
  static String messages;
  Future<void> update() async {
    cookie = Session().getCookie();
    profile = await Session().get('https://fallmerayer.digitalesregister.it/v2/api/profile/get');
    messages = await Session().post('https://fallmerayer.digitalesregister.it/v2/api/message/getMyMessages', {'filterByLabelName': ''});
    GetData update = new GetData();
    return;
  }
}