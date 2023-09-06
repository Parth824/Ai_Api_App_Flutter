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
  String k = "";
  bool r = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              id = "";
              k = "";
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)),
      ),
      body: (url != null)
          ? Column(
              children: [
                Container(height: 200, child: Image.network(url!)),
                SizedBox(
                  height: 10,
                ),
                Text("new Image"),
                SizedBox(
                  height: 10,
                ),
                (k != "")
                    ? Expanded(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Image.network(k)))
                    : (r)
                        ? Expanded(child: Container(width: MediaQuery.of(context).size.width,child: Center(child: CircularProgressIndicator())))
                        : Container(),
              ],
            )
          : Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          
          await getApi();

          await getimage();
          print("$k my");
          setState(() {});
        },
        child: Center(
          child: Icon(Icons.conveyor_belt),
        ),
      ),
    );
  }

  getApi() async {
    r = true;
          setState(() {
            
          });
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
      setState(() {});
    }
  }

  getimage() async {
    await Future.delayed(
      Duration(seconds: 10),
      () {},
    );
    Map<String, String>? heder = {
      "Authorization": "Token r8_C7RkOmDU2O4DeYNnlMIYb12boFNI7R33T1S5i"
    };
    print(id);
    http.Response response = await http.get(
        Uri.parse("https://api.replicate.com/v1/predictions/${id}"),
        headers: heder);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // String? imagurl = data['output'];
      print(data);
      if (data['output'] == null) {
        getimage();
      } else {
        k = data['output'];
        setState(() {});
        return;
      }
      // print(data['output']);
    }
  }
}
