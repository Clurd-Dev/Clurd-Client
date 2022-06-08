import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'serverio.dart';
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

  Future<void> remove(String path) async{
    //print(path);
    var url = Uri.parse('http://$serverip/remove');
    var response = await http.post(url, body: '{"folder": "$path"}');
    if(response.body == "1"){
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
    }else{
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
                  Text('Error during deleting of file, please an issue on Github if is not a server permission error'),
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

  }

  final ServerIO io = ServerIO(serveripa: "127.0.0.1:8000");

  @override

  Widget build(BuildContext context) {
    io.getpath().then((String pathrsp) {
      path = pathrsp;
      io.fetchfiles(pathrsp).then((List<dynamic> filesFromRsp) {
        files = filesFromRsp;
        if(checked == false){
          checked = true;
          setState(() {});
        }
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(serverip),
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
                      semanticLabel: 'Folder',
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
                      semanticLabel: 'File',
                    ),
                    title: Text(files[index]["file"]),
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
                                    icon:  const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 24.0,
                                      semanticLabel: 'Remove',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.grey,
                                    ),
                                    onPressed: () {
                                      remove('$path/${files[index]["file"]}');
                                    },
                                    label: const Text(
                                      'Remove',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                  )
                              ),
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
                                )
                                ),
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
