import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'serverio.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class CpMvview extends StatefulWidget {
  String serverip, pathTo, NameFile, username, password;
  CpMvview(
      {super.key,
      required this.serverip,
      required this.pathTo,
      required this.NameFile,
      required this.username,
      required this.password});
  @override
  _CpMvview createState() => _CpMvview(
      serverip: serverip,
      OldPath: pathTo,
      NameFile: NameFile,
      username: username,
      password: password);
}

class _CpMvview extends State<CpMvview> {
  String path = "";
  String serverip, OldPath, NameFile, username, password;
  String virt_path = "";
  List<dynamic> files = <dynamic>[];
  bool checked = false;
  _CpMvview(
      {required this.serverip,
      required this.OldPath,
      required this.NameFile,
      required this.username,
      required this.password});

  void navigateFolder(String file) {
    final ServerIO io =
        ServerIO(serveripa: serverip, username: username, password: password);
    path = '$path/$file';
    virt_path = '$virt_path/$file';
    io.fetchfiles(files, path, context).then((List<dynamic> filesFromRsp) {
      files = filesFromRsp;
      setState(() {});
    });
  }

  void goBack() {
    final ServerIO io =
        ServerIO(serveripa: serverip, username: username, password: password);
    var tempath = path.split("/");
    tempath.removeLast();
    path = tempath.join("/");
    io.fetchfiles(files, path, context).then((List<dynamic> filesFromRsp) {
      files = filesFromRsp;
      setState(() {});
    });
  }

  void copy() async {
    Navigator.pop(context);
    var url = Uri.parse('http://$serverip/api/copy');
    // var response = await http.post(url,
    //     body: '{"folder": "$OldPath", "new": "$path/$NameFile"}');
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request =
        http.Request('POST', Uri.parse('http://localhost:5004/api/copy'));
    request.bodyFields = {
      'oldpath': OldPath,
      'newpath': "$path/$NameFile",
      'username': username,
      'password': password
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      if (await response.stream.bytesToString() == "true") {
        return showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('File copied successfully'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('File copied successfully in $path/$NameFile'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        Navigator.pop(context);
        return showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error during copy of file'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Error during copy of file in $path/$NameFile'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  void move() async {
    // var url = Uri.parse();
    // var response = await http.post(url,
    //     body: '{"folder": "$OldPath", "new": "$path/$NameFile"}');
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request('POST', Uri.parse('http://$serverip/api/move'));
    request.bodyFields = {'oldpath': OldPath, 'newpath': "$path/$NameFile"};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      if (await response.stream.bytesToString() == "true") {
        Navigator.pop(context);
        return showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('File moved successfully'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('File moved successfully in $path/$NameFile'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        Navigator.pop(context);
        return showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error during move of file'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Error during move of file in $path/$NameFile'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ServerIO io =
        ServerIO(serveripa: serverip, username: username, password: password);
    Color button = const Color.fromARGB(255, 103, 153, 223);
    if (checked == false) {
      io.getpath().then((String pathrsp) {
        path = pathrsp;
        io
            .fetchfiles(files, pathrsp, context)
            .then((List<dynamic> filesFromRsp) {
          files = filesFromRsp;
          checked = true;
          setState(() {});
        });
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(serverip), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.subdirectory_arrow_left),
          tooltip: 'Go back folder',
          onPressed: () {
            goBack();
          },
        )
      ]),
      body: Stack(alignment: Alignment.bottomCenter, children: [
        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: files.length,
          itemBuilder: (BuildContext context, int index) {
            if (files[index]["Dir"] == true) {
              return Container(
                color: Colors.green,
                child: Material(
                  child: ListTile(
                    leading: const Icon(
                      Icons.folder,
                      color: Color.fromARGB(255, 39, 141, 213),
                      size: 32.0,
                      semanticLabel: 'Folder',
                    ),
                    title: Text(files[index]["Name"]),
                    tileColor: Colors.white30,
                    onTap: () {
                      navigateFolder(files[index]["Name"]);
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
                            semanticLabel: 'File',
                          ),
                          title: Text(files[index]["Name"]),
                          tileColor: Colors.white30)));
            }
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
        Container(
          height: 150,
          child: Column(
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    copy();
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy file here")),
              const Text("\n"),
              ElevatedButton.icon(
                  onPressed: () {
                    move();
                  },
                  icon: const Icon(Icons.cut),
                  label: const Text("Move file here"))
            ],
          ),
        )
      ]),
    );
  }
}
