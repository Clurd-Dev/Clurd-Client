import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Uploadview extends StatefulWidget {
  String serverip, path;
  Uploadview({super.key, required this.serverip, required this.path});
  @override
  _Uploadview createState() => _Uploadview(serverip: serverip, path: path);
}

class _Uploadview extends State<Uploadview> {
  late String serverip, path;
  List<dynamic> files = <dynamic>[];
  bool checked = false;
  _Uploadview({required this.serverip, required this.path});

  void upload() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      List<File> files = result.paths.map((pathraw) => File(pathraw!)).toList();
      print(path);
      print(path.replaceAll("/", "|"));
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://${serverip}/api/upload/${path.replaceAll("/", "|")}'));
      files.forEach((fileraw) {
        request.files.add(http.MultipartFile(
            'picture', fileraw.readAsBytes().asStream(), fileraw.lengthSync(),
            filename: fileraw.path.replaceAll("\\", "/").split("/").last));
      });
      var res = await request.send();
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    Color button = const Color.fromARGB(255, 103, 153, 223);

    return Scaffold(
      appBar: AppBar(title: const Text("Upload a file")),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color.fromARGB(255, 1, 159, 251),
          ),
          onPressed: () {
            upload();
          },
          child: const Text(
            'Pick files',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
