import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Map<String, String> headers;

class Session {
  Future<String> get(String url) async {
    http.Response response = await http.get(url, headers: headers);
    print(response.body);
    return response.body;
  }

  Future<String> login(String url, dynamic data) async {
    if (headers != null)
      headers.clear();
    http.Response response = await http.post(url, body: jsonEncode(data), headers: headers);
    updateCookie(response);
    print(response.body);
    return response.body;
  }

  Future<String> post(String url, dynamic data) async {
    http.Response response = await http.post(url, body: jsonEncode(data), headers: headers);
    print(response.body);
    return response.body;
  }

  void updateCookie(http.Response response) {
    String raw = response.headers['set-cookie'];
    int i_php = raw.indexOf('PHP');
    int j_php = raw.indexOf(';', i_php);
    int i_sess = raw.lastIndexOf('registerSession');
    int j_sess = raw.indexOf(';', i_sess);
    String cookie = raw.substring(i_php, j_php)+'; '+raw.substring(i_sess, j_sess);
    headers = {'Cookie': cookie};
  }
}