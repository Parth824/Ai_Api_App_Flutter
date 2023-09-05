import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class ConverPage extends StatefulWidget {
  const ConverPage({super.key});

  @override
  State<ConverPage> createState() => _ConverPageState();
}

class _ConverPageState extends State<ConverPage> {
  String id = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: (url != null)
          ? Column(
              children: [
                Image.network(url!),
                SizedBox(
                  height: 10,
                ),
                Text("new Image"),
              ],
            )
          : Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getApi();
          String? k = await getimage();
          print(k);
        },
        child: Center(
          child: Icon(Icons.conveyor_belt),
        ),
      ),
    );
  }

  getApi() async {
    Map<String, String>? heder = {
      "Authorization": "Token r8_C7RkOmDU2O4DeYNnlMIYb12boFNI7R33T1S5i"
    };

    Map? body = {
      "version":
          "7de2ea26c616d5bf2245ad0d5e24f0ff9a6204578a5c876db53142edd9d2cd56",
      "input": {"image": url}
    };
    http.Response response = await http.post(
      Uri.parse("https://api.replicate.com/v1/predictions"),
      headers: heder,
      body: jsonEncode(body),
    );
    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      print(data['id']);
      id = data['id'];
    }
    
  }

  getimage() async {
    Map<String, String>? heder = {
      "Authorization": "Token r8_C7RkOmDU2O4DeYNnlMIYb12boFNI7R33T1S5i"
    };
    http.Response response = await http.post(
        Uri.parse("https://api.replicate.com/v1/predictions/$id"),
        headers: heder);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // String? imagurl = data['output'];
      print(data);
      print(data['output']);
      // return "";
    }
  }
}
