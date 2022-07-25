import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'serverio.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import './cp_mv_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Serverview extends StatefulWidget {
  String serverip;
  Serverview({super.key, required this.serverip});
  @override
  _Serverview createState() => _Serverview(serverip: serverip);
}

class _Serverview extends State<Serverview> {
  String path = "";
  String serverip = "";
  String virt_path = "";
  List<dynamic> files = <dynamic>[];
  bool checked = false;
  _Serverview({required this.serverip});

  Future<void> remove(String path) async {
    // var url = Uri.parse();
    // var response = await http.post(url, body: '{"folder": "$path"}');
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request =
        http.Request('POST', Uri.parse('http://$serverip/api/delete'));
    request.bodyFields = {'path': path};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      if (await response.stream.bytesToString() == "true") {
        navigateFolder("");
        Navigator.pop(context);
        return showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('File successfully removed'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text('File successfully removed'),
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
        navigateFolder("");
        Navigator.pop(context);
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error during removing of file'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text(
                        'Error during deleting of file, please an issue on Github if is not a server permission error'),
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

  void navigateFolder(String file) {
    final ServerIO io = ServerIO(serveripa: serverip);
    path = '$path/$file';
    virt_path = '$virt_path/$file';
    io.fetchfiles(path).then((List<dynamic> filesFromRsp) {
      files = filesFromRsp;
      setState(() {});
    });
  }

  void goBack() {
    final ServerIO io = ServerIO(serveripa: serverip);
    var tempath = path.split("/");
    tempath.removeLast();
    path = tempath.join("/");
    io.fetchfiles(path).then((List<dynamic> filesFromRsp) {
      files = filesFromRsp;
      setState(() {});
    });
  }

  void rename(String oldPath) async {
    var newFile = await prompt(context,
        title: const Text('Enter a new name for the file'),
        hintText: 'Filename');

    if (newFile != null) {
      var pathsplitted = oldPath.split("/");
      pathsplitted.removeLast();
      pathsplitted.add(newFile);
      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      var request =
          http.Request('POST', Uri.parse('http://$serverip/api/rename'));
      request.bodyFields = {'old': oldPath, 'new': pathsplitted.join("/")};
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        if (await response.stream.bytesToString() == "true") {
          navigateFolder("");
          return showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('File successfully renamed'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: const <Widget>[
                      Text('File successfully renamed'),
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
          navigateFolder("");
          return showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('File is not renamed'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: const <Widget>[
                      Text('Error during renaming of file'),
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
  }

  void download(String filepath, String filename) async {
    http.Client client = new http.Client();
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request('POST', Uri.parse('http://$serverip/api/file'));
    request.bodyFields = {'path': filepath};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var bytes = await response.stream.toBytes();
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = new File('$dir/$filename');
      await file.writeAsBytes(bytes);
      Navigator.of(context).pop();
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('File downloaded successfully'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('$filename downloaded successfully'),
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
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ServerIO io = ServerIO(serveripa: serverip);
    Color button = const Color.fromARGB(255, 103, 153, 223);
    if (checked == false) {
      io.getpath().then((String pathrsp) {
        path = pathrsp;
        print(path);
        io.fetchfiles(pathrsp).then((List<dynamic> filesFromRsp) {
          files = filesFromRsp;
          //print(files);
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
      body: Center(
        child: ListView.separated(
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
                    tileColor: Colors.white30,
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return ListView(
                            padding: const EdgeInsets.all(8),
                            children: <Widget>[
                              SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.white,
                                    size: 24.0,
                                    semanticLabel: 'Download file',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: button,
                                  ),
                                  onPressed: () {
                                    download(files[index]["FullPath"],
                                        files[index]["Name"]);
                                  },
                                  label: const Text(
                                    'Download file',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 10,
                                thickness: 2,
                                color: Colors.white10,
                              ),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.file_copy,
                                    color: Colors.white,
                                    size: 24.0,
                                    semanticLabel: 'Copy/Move file',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: button,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CpMvview(
                                              serverip: serverip,
                                              pathTo: files[index]["FullPath"],
                                              NameFile: files[index]["Name"])),
                                    );
                                  },
                                  label: const Text(
                                    'Copy/Move file',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 10,
                                thickness: 2,
                                color: Colors.white10,
                              ),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 24.0,
                                    semanticLabel: 'Rename',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: button,
                                  ),
                                  onPressed: () {
                                    rename(files[index]["FullPath"]);
                                  },
                                  label: const Text(
                                    'Rename',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 10,
                                thickness: 2,
                                color: Colors.white10,
                              ),
                              SizedBox(
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 24.0,
                                      semanticLabel: 'Remove',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      primary: button,
                                    ),
                                    onPressed: () {
                                      remove(files[index]["FullPath"]);
                                    },
                                    label: const Text(
                                      'Remove',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  )),
                              const Divider(
                                height: 10,
                                thickness: 2,
                                color: Colors.white10,
                              ),
                              SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  )),
                            ],
                          );
                        },
                      );
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
