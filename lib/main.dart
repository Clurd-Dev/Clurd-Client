import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'serverview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clurd Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Add a server'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> entries = <String>[];

  void addserver() async {
    var serverip = await prompt(context,
        title: const Text('Enter a server IP with the port'),
        hintText: 'Server IP with port');
    if (serverip != null) {
      entries.add(serverip.toString());
      writeservers();
      setState(() {});
    }
    else {
      Alert(
        context: context,
        type: AlertType.error,
        title: "Server IP is not valid",
        desc: "The server IP is not valid",
        buttons: [
          DialogButton(
            child: const Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    }
  }

  void writeservers() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/servers.json';
    File file = File(filePath);
    file.writeAsString(jsonEncode(entries));
  }

  void parse_servers() async{
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/servers.json';
    File file = File(filePath);
    var servers = jsonDecode(await file.readAsString());
    if (servers == null) {
      entries = [];
    }
    else{
      entries = servers;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    parse_servers();
    const title = 'Clurd';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: Container(
          child: Column(
            children: [
              const Text("\n"),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 1, 159, 251),
                  ),
                  onPressed: () {
                    addserver();
                  },
                  child: const Text(
                    'Add a server',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Container(
                height: 200,
                width: 200,
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: entries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 50,
                        width: 200,
                        child: Center(
                          child: TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            onPressed: () {
                              var current = "";
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Serverview(
                                        serverip: '${entries[index]}')),
                              );
                            },
                            child: Text('${entries[index]}'),
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
