import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as dartConvert;
import 'package:html_unescape/html_unescape.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello app',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Hello app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Future<JsonIpApi> futureIpApi;
  Future<JsonSalutApi> futureSalutApi;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    futureIpApi = fetchJsonIpApiData();
    futureIpApi.then((ipApiData) {
      setState(() {
        futureSalutApi = fetchJsonSalutApiData(ipApiData.strIp);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<JsonSalutApi>(
              future: futureSalutApi,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SelectableText(snapshot.data.strUnescapedHello);
                } else if (snapshot.hasError) {
                  return SelectableText(
                      "${snapshot.error}\nYou might need to disable AdBlock");
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class JsonIpApi {
  final String strIp;

  JsonIpApi({this.strIp});

  factory JsonIpApi.parseJson(Map<String, dynamic> json) {
    return JsonIpApi(strIp: json['query']);
  }

  String get ip {
    return strIp;
  }
}

Future<JsonIpApi> fetchJsonIpApiData() async {
  final response = await http.get('http://ip-api.com/json/');

  if (response.statusCode == 200) {
    var responseBody = dartConvert.jsonDecode(response.body);
    return JsonIpApi.parseJson(responseBody);
  } else {
    throw Exception('Failed to get data from Ip-Api.');
  }
}

class JsonSalutApi {
  final String strHello;
  final String strUnescapedHello;

  JsonSalutApi({this.strHello, this.strUnescapedHello});

  factory JsonSalutApi.parseJson(Map<String, dynamic> json) {
    var unescape = HtmlUnescape();
    return JsonSalutApi(
        strHello: json['hello'],
        strUnescapedHello: unescape.convert(json['hello']));
  }
}

Future<JsonSalutApi> fetchJsonSalutApiData(userIp) async {
  final response =
      await http.get('https://fourtonfish.com/hellosalut/?ip=' + userIp);
  if (response.statusCode == 200) {
    var responseBody = dartConvert.jsonDecode(response.body);
    return JsonSalutApi.parseJson(responseBody);
  } else {
    throw Exception('Failed to get data from Salut api.');
  }
}
