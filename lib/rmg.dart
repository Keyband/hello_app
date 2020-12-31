import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert' as dartConvert;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Meal Generator',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'Random Meal Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({this.title = 'Title'});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Album> futureAlbum;

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'It was not possible to open $url.';
    }
  }

  void _newMeal() {
    setState(() {
      print('Fetching new food');
      futureAlbum = fetchAlbum();
    });
  }

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.amber, Colors.yellow])),
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 32),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.amber[800], width: 2),
                borderRadius: BorderRadius.circular(8.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FutureBuilder<Album>(
                  future: futureAlbum,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            snapshot.data.strMeal,
                            style: new TextStyle(
                                fontSize: 24.0,
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w300,
                                fontFamily: "Roboto"),
                          ),
                          SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.amber[800], width: 4),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2.0),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    _launchURL(snapshot.data.strVideoUrl);
                                  },
                                  child: Image.network(
                                    snapshot.data.strMealThumb,
                                    fit: BoxFit.cover,
                                    width: 255.0,
                                    height: 255.0,
                                    loadingBuilder: (context, child, progress) {
                                      return progress == null
                                          ? child
                                          : Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              width: 255.0,
                                              height: 255.0,
                                              child:
                                                  CircularProgressIndicator());
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Tap the image to see a video!',
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 12),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'About',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Type: ' + snapshot.data.strCategory),
                              Text('Region: ' + snapshot.data.strRegion),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Ingredients',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(snapshot.data.lstStrIngredients.join(', '))
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                Spacer(),
                RaisedButton(
                  child: Text('Get a new meal!'),
                  onPressed: _newMeal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Album {
  final String strMeal;
  final String strMealThumb;
  final String strVideoUrl;
  final String strCategory;
  final String strRegion;
  final List<String> lstStrIngredients;

  Album(
      {this.strMeal,
      this.strMealThumb,
      this.strVideoUrl,
      this.strCategory,
      this.strRegion,
      this.lstStrIngredients});

  factory Album.fromJson(Map<String, dynamic> json) {
    List<String> localLstStrIngredients = [];
    json.forEach((key, value) {
      if (key is String) {
        if (key.contains('strIngredient')) {
          if (value != '') {
            localLstStrIngredients.add(value);
          }
        }
      }
    });
    return Album(
        strMeal: json['strMeal'],
        strMealThumb: json['strMealThumb'],
        strVideoUrl: json['strYoutube'],
        strCategory: json['strCategory'],
        strRegion: json['strArea'],
        lstStrIngredients: localLstStrIngredients);
  }
}

Future<Album> fetchAlbum() async {
  final response =
      await http.get('https://www.themealdb.com/api/json/v1/1/random.php');

  if (response.statusCode == 200) {
    var responseBody = dartConvert.jsonDecode(response.body);
    return Album.fromJson(responseBody['meals'][0]);
  } else {
    throw Exception('Failed to load album');
  }
}
