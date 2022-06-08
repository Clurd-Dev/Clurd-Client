import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerIO {
  late String serveripa;
  ServerIO({required this.serveripa});
  Future<String> getpath() async {
    var response = await http.get(Uri.parse("http://$serveripa/getconfig"));
    return await jsonDecode(response.body)["path"];
  }
  Future<List<dynamic>> fetchfiles(String path) async {
    var url = Uri.parse('http://$serveripa/getfiles');
    var response = await http.post(url, body: '{"folder": "$path"}');
    return jsonDecode(response.body);
  }
}
