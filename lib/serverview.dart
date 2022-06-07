import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Serverview extends StatefulWidget {
  String serverip;
  Serverview({super.key, required this.serverip});
  @override
  _Serverview createState() => _Serverview(serverip: serverip);
}

class _Serverview extends State<Serverview> {
  String serverip = "";
  String path = "";
  _Serverview({required this.serverip});
  List<dynamic> files = <dynamic>["ciao"];

  Future<String> getpath() async {
    var response = await http.get(Uri.parse("http://$serverip/getconfig"));
    return await jsonDecode(response.body)["path"];
  }

  void fetchfiles() async {
    var url = Uri.parse('http://$serverip/getfiles');
    var response = await http.post(url, body: '{"folder": "$path"}');
    setState(() {files = jsonDecode(response.body);});
  }

  @override
  Widget build(BuildContext context) {
    getpath().then((String pathrsp) {
      path = pathrsp;
      fetchfiles();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: files.length,
          itemBuilder: (BuildContext context, int index) {
            if (files[index]["dir"] == true) {
              return Container(
                color: Colors.green,
                child: Material(
                  child: ListTile(
                    leading: const Icon(
                      Icons.folder,
                      color: Color.fromARGB(255, 39, 141, 213),
                      size: 32.0,
                      semanticLabel: 'Text to announce in accessibility modes',
                    ),
                    title: Text(files[index]["file"]),
                    tileColor: Colors.white30,
                    onTap: () {
                      print("ciao");
                    },
                  ),
                ),
              );
            } else {
              return Container(
                color: Colors.green,
                child: Material(
                  child: ListTile(
                    leading: const Icon(
                      Icons.description,
                      color: Color.fromARGB(255, 39, 141, 213),
                      size: 32.0,
                      semanticLabel: 'Text to announce in accessibility modes',
                    ),
                    title: Text(files[index]["file"]),
                    tileColor: Colors.white30,
                    onTap: () {
                      print("ciao");
                    },
                  ),
                ),
              );
            }
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
    );
  }
}
