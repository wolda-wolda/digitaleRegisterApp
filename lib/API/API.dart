import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:digitales_register_app/Data/Load&Store.dart';

Map<String, String> headers;
String cookie = 'empty';
class Session {
  Future<String> get(String url) async {
    http.Response response = await http.get(url, headers: headers);
    return response.body;
  }
  String getCookie() {
    return cookie;
  }
  Future<String> login(String url, dynamic data) async {
    if (headers != null)
      headers.clear();
    http.Response response = await http.post(url, body: jsonEncode(data), headers: headers);
    print(response.body);
    if (jsonDecode(response.body)['error'] == null) {
      updateCookie(response);
    }
    await Data().updateall();
    return response.body;
  }

  Future<String> post(String url, dynamic data) async {
    http.Response response = await http.post(url, body: jsonEncode(data), headers: headers);
    return response.body;
  }

  void updateCookie(http.Response response) {
    String raw = response.headers['set-cookie'];
    int iPHP = raw.indexOf('PHP');
    int jPHP = raw.indexOf(';', iPHP);
    int iSession = raw.lastIndexOf('registerSession');
    int jSession = raw.indexOf(';', iSession);
    cookie = raw.substring(iPHP, jPHP)+'; '+raw.substring(iSession, jSession);
    headers = {'Cookie': cookie};
  }
}

class Date {
  final String date;
  Date(this.date);

  factory Date.format(String enDate) {
    DateTime date = new DateFormat('yyyy-MM-dd').parse(enDate);

    return Date(
        DateFormat('EEEE, d. MMM yyyy', 'de_DE').format(date).toString());
  }
}
