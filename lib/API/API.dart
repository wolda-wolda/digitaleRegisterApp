import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
Map<String, String> headers;
class Session {
  Future<String> get(String url) async {
    print(headers);
    http.Response response = await http.get(url, headers: headers);
    print(response.body);
    return response.body;
  }

  Future<String> post(String url, dynamic data) async {
    if (headers != null)
      headers.clear();
    http.Response response = await http.post(url, body: jsonEncode(data), headers: headers);
    updateCookie(response);
    print(response.body);
    return response.body;
  }

  void updateCookie(http.Response response) {
    print(headers);
    headers = response.headers;
    print(headers);
  }
}