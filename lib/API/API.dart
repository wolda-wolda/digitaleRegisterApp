import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

Map<String, String> headers;
String cookie = 'empty';
class Session {
  Future<File> downloadFile(String url, String filename) async {
    var status = await Permission.storage.status;
    if (!status.isGranted)
      await Permission.storage.request();
    var req = await http.get(url, headers: headers);
    String path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS) + '/' + filename;
    File file = new File(path);
    print(file.absolute.path);
    await file.writeAsBytes(req.bodyBytes);
    OpenFile.open(path);
    return file;
  }

  Future<String> get(String url) async {
      try {
        http.Response response = await http.get(url, headers: headers).timeout(
            Duration(seconds: 2),
            onTimeout: () {
              throw Exception;
            }
        );
        return response.body;
      } on Exception {
        return 'e';
      }
    }
  String getCookie() {
    return cookie;
  }
  Future<String> login(String url, dynamic data) async {
    http.Response response;
    if (headers != null){
      headers.clear();
    }
      try {
        response = await http.post(
            url, body: jsonEncode(data), headers: headers,).timeout(
            Duration(seconds: 2),
            onTimeout: () {
              throw Exception;
            });
      }on Exception {
        return 'e';
      }catch (exception){
        return 'e';
      }
      if(response.statusCode!=200){
        return 'e';
      }
    print(response.body);
    if (jsonDecode(response.body)['error'] == null) {
      updateCookie(response);
    }
    return response.body;
  }

  Future<String> post(String url, dynamic data) async {
    try {
      http.Response response = await http.post(url, body: jsonEncode(data), headers: headers).timeout(
          Duration(seconds: 2),
          onTimeout: () {
            throw Exception;
          }
      );
      return response.body;
    } on Exception{
      return 'e';
    }
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
