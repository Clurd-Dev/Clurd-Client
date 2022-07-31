import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'serverview.dart';

class Login extends StatefulWidget {
  String serverIP;
  Login({super.key, required this.serverIP});
  @override
  _Login createState() => _Login(serverIP: serverIP);
}

class _Login extends State<Login> {
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  String serverIP;
  _Login({required this.serverIP});

  void login() async {
    var username = usernamecontroller.text;
    var password = md5.convert(utf8.encode(passwordcontroller.text)).toString();
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request =
        http.Request('POST', Uri.parse('http://${serverIP}/api/login'));
    request.bodyFields = {'user': username, 'password': password};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      if (await response.stream.bytesToString() == "true") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Serverview(
                  serverip: serverIP, username: username, password: password)),
        );
      } else {
        return showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Login failed"),
                content: const Text(
                    "Please check if username or password is correct"),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
      ;
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Login to $serverIP")),
        body: Padding(
            padding: const EdgeInsets.all(54.0),
            child: Column(children: [
              const Text("Username"),
              TextField(controller: usernamecontroller),
              const Text("\n"),
              const Text("Password"),
              TextField(
                  controller: passwordcontroller,
                  obscureText: true,
                  autocorrect: false),
              const Text("\n"),
              TextButton(onPressed: login, child: const Text("Login"))
            ])));
  }
}
