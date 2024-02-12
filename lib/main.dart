import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:monica_app/token.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Monica CRM',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.black,
      ),
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _page = 0;
  Future<String> apiCall(
      {required Uri endpoint, Map<String, dynamic>? body}) async {
    var response =
        await http.get(endpoint, headers: {"Authorization": "Bearer $token"});
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String>? getMe() async {
    var response =
        await apiCall(endpoint: Uri.parse("http://172.20.10.2:8080/api/me"));
    var jsondata = jsonDecode(response);
    return jsondata["data"]["name"];
  }

  Future<List<dynamic>>? getContacts() async {
    var response = await apiCall(
        endpoint:
            Uri.parse("http://172.20.10.2:8080/api/contacts?page=$_page"));
    var jsondata = jsonDecode(response);
    return jsondata["data"];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Account',
            ),
            FutureBuilder<String>(
                future: getMe(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data!,
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    );
                  } else {
                    return const Center();
                  }
                }),
            const Text("Contacts"),
            FutureBuilder(
                future: getContacts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                        children: snapshot.data!
                            .map((c) => Text(c["complete_name"]))
                            .toList());
                  } else {
                    return const Center();
                  }
                }),
            Text('Page $_page'),
            CupertinoTextField(
              onChanged: (value) {
                setState(() {
                  _page = int.tryParse(value)??0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
