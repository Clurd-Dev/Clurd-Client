import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerIO {
  late String serveripa;
  ServerIO({required this.serveripa});
  Future<String> getpath() async {
    var response = await http.get(Uri.parse("http://$serveripa/api/config"));
    return response.body;
  }

  Future<List<dynamic>> fetchfiles(String path) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request =
        http.Request('POST', Uri.parse('http://$serveripa/api/files'));
    request.bodyFields = {'path': path};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return jsonDecode(await response.stream.bytesToString());
    } else {
      List<dynamic> error = [];
      print(response.reasonPhrase);
      return error;
    }
  }
}
