// Bg image credit: https://cc0textures.com/view?id=PavingStones065
// Logo image credit: https://www.flaticon.com/free-icon/planet-earth_921490?term=globe&page=1&position=23&related_item_id=921490
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
  Future<StrIpify> futureIpify;
  Future<JsonIpApi> futureIpApi;
  Future<JsonSalutApi> futureSalutApi;
  String strHelloNative = '';
  String strLogin = '';
  String strPassword = '';
  String strUserIp = '';
  bool bMissingInfo = false;
  bool bLoggedIn = false;
  Map<String, String> mUserInfo;

  @override
  void initState() {
    super.initState();
    futureIpify = fetchIpifyData();
    futureIpify.then((ipApifyData) {
      setState(() {
        strUserIp = ipApifyData.strIp;
        futureSalutApi = fetchJsonSalutApiData(ipApifyData.strIp);
        futureSalutApi.then((value) {
          ;
        });
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
        child: Stack(fit: StackFit.expand, children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/bg.jpg'), fit: BoxFit.cover)),
          ),
          Container(color: Colors.white.withOpacity(0.3)),
          Container(
            child: bLoggedIn
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                offset: Offset(4, 4),
                                blurRadius: 16.0,
                                spreadRadius: 8.0,
                                color: Colors.black.withOpacity(0.2))
                          ],
                          color: Colors.green[300],
                        ),
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            SelectableText(strHelloNative + '!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                )),
                            Divider(
                              color: Colors.white,
                              height: 2,
                            ),
                            SelectableText('Your IP is: ' + strUserIp,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                )),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      RaisedButton(
                        onPressed: () {
                          final snackBar = SnackBar(
                              content:
                                  Text('Have a great day, ' + strLogin + '!'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          setState(() {
                            bLoggedIn = false;
                          });
                        },
                        child: Text('Sign out'),
                        color: Colors.green[200],
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FutureBuilder<JsonSalutApi>(
                        future: futureSalutApi,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            strHelloNative = snapshot.data.strUnescapedHello;
                            return Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      offset: Offset(4, 4),
                                      blurRadius: 16.0,
                                      spreadRadius: 8.0,
                                      color: Colors.black.withOpacity(0.2))
                                ],
                                color: Colors.green[400],
                              ),
                              child: Stack(
                                children: [
                                  SelectableText(
                                      snapshot.data.strUnescapedHello,
                                      style: TextStyle(
                                          color: Colors.green[600],
                                          fontSize: 38)),
                                  SelectableText(
                                      snapshot.data.strUnescapedHello,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                      ))
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return SelectableText(
                                "${snapshot.error}\nYou might need to disable AdBlock");
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                offset: Offset(4, 4),
                                blurRadius: 16.0,
                                spreadRadius: 8.0,
                                color: Colors.black.withOpacity(0.2))
                          ],
                          color: Colors.green[300],
                        ),
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextField(
                              autocorrect: false,
                              onChanged: (text) {
                                strLogin = text;
                              },
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: (bMissingInfo && strLogin == '')
                                      ? Colors.red[50]
                                      : Colors.green[50],
                                  border: OutlineInputBorder(),
                                  labelText: 'Login',
                                  contentPadding: EdgeInsets.all(8)),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              obscureText: true,
                              autocorrect: false,
                              onChanged: (text) {
                                strPassword = text;
                              },
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: (bMissingInfo && strPassword == '')
                                      ? Colors.red[50]
                                      : Colors.green[50],
                                  border: OutlineInputBorder(),
                                  labelText: 'Password',
                                  contentPadding: EdgeInsets.all(8)),
                            ),
                            SizedBox(height: 8),
                            RaisedButton(
                              onPressed: () {
                                if (strLogin == '' || strPassword == '') {
                                  final snackBar = SnackBar(
                                      content:
                                          Text('Login or password missing!'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  setState(() {
                                    bMissingInfo = true;
                                  });
                                } else {
                                  final snackBar = SnackBar(
                                      content: Text(strHelloNative +
                                          ' ' +
                                          strLogin +
                                          ', you have successfully logged in!'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  setState(() {
                                    bMissingInfo = false;
                                    bLoggedIn = true;
                                  });
                                }
                              },
                              child: Text('Sign in'),
                              color: Colors.green[200],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
          ),
        ]),
      ),
    );
  }
}

class StrIpify {
  final String strIp;
  StrIpify({this.strIp});
  factory StrIpify.parseResponse(String response) {
    return StrIpify(strIp: response);
  }
}

Future<StrIpify> fetchIpifyData() async {
  final response = await http.get('https://api.ipify.org');
  if (response.statusCode == 200) {
    return StrIpify.parseResponse(response.body);
  } else {
    throw Exception('Failed to get data from Ipify.');
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
        strUnescapedHello: unescape.convert(
          json['hello'],
        ));
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
