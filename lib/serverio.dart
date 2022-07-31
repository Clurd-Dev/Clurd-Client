import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class ServerIO {
  late String serveripa, username, password;
  ServerIO(
      {required this.serveripa,
      required this.username,
      required this.password});
  Future<String> getpath() async {
    var response = await http.get(Uri.parse("http://$serveripa/api/config"));
    var config = jsonDecode(response.body);
    return config["path"];
  }

  Future<List<dynamic>> fetchfiles(
      List<dynamic> oldpath, String path, BuildContext context) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request =
        http.Request('POST', Uri.parse('http://$serveripa/api/files'));
    request.bodyFields = {
      'path': path,
      'username': username,
      'password': password
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    try {
      if (response.statusCode == 200) {
        return jsonDecode(await response.stream.bytesToString());
      } else {
        List<dynamic> error = [];
        print(response.reasonPhrase);
        return error;
      }
    } catch (e) {
      ToastContext().init(context);
      Toast.show("Can't go back through home",
          duration: Toast.lengthLong, gravity: Toast.bottom);
      print(e);
      return oldpath;
    }
  }
}
