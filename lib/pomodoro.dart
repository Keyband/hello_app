// Don't forget to credit the icon: https://www.flaticon.com/free-icon/tomato_1412511?related_item_id=1413626&term=tomato
// BG image: https://www.pexels.com/photo/red-tomatoes-on-board-2899682/
// Link teaching some things about the glassmorphism: https://www.youtube.com/watch?v=mCyVx2rwd-U
// Font used: https://fonts.google.com/specimen/Montserrat
import 'dart:ui';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:audioplayers/audio_cache.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Flutter',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Montserrat',
      ),
      home: MyHomePage(title: 'Pomodoro Flutter'),
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
  static const String urlToSfx =
      'https://raw.githubusercontent.com/Keyband/e/main/timeUp.wav?token=AHJXRPC2DZTUBVVDBUV7OLC76KB7K';
  Timer _timer = Timer.periodic(Duration(days: 1), (timer) {});
  int pomodoroTime = 25 * 60;
  bool running = false;
  bool isBreak = false;
  int numberOfBreaks = 0;
  static var player = AudioPlayer();
  var duration = player.setUrl(urlToSfx, preload: true);

  void playSfx() async {
    player.play();
    Future.delayed(const Duration(milliseconds: 400), () {
      player.stop();
    });

    // AudioCache cache = new AudioCache();
    // return await cache.play("timeUp.wav", isNotification: true);
  }

  void startTimer({int startTimeInSeconds: 25 * 60}) {
    pomodoroTime = startTimeInSeconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        running = true;
        pomodoroTime--;
        if (pomodoroTime <= 0) {
          _timer.cancel();
          running = false;
          playSfx();
          if (isBreak) {
            isBreak = false;
            startTimer();
          } else {
            isBreak = true;
            numberOfBreaks++;
            startTimer(
                startTimeInSeconds:
                    (numberOfBreaks % 4 == 0) ? 10 * 60 : 5 * 60);
          }
        }
      });
    });
  }

  void pauseTimer({resetTime: false}) {
    setState(() {
      running = false;
      _timer.cancel();
      if (resetTime) {
        pomodoroTime = 25 * 60;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Pomodoro Timer',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Colors.red,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.stop),
                onPressed: () {
                  playSfx();
                  pauseTimer(resetTime: true);
                },
              )
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(running ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            if (!running) {
              if (pomodoroTime != 25 * 60) {
                startTimer(startTimeInSeconds: pomodoroTime);
              } else {
                startTimer();
              }
            } else {
              pauseTimer();
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // appBar: AppBar(
        //   title: Text(widget.title),
        // ),
        body: Stack(fit: StackFit.expand, children: <Widget>[
          Container(
            padding: EdgeInsets.all(64),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/bg.jpg'),
                    fit: BoxFit.cover)),
          ),
          Container(
              color: Colors.white.withOpacity(
                  0.2)), // Used to make the BG image a little less intense
          Column(
              // padding: EdgeInsets.all(16),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GlassPanel(
                    child: Text(
                  '${(pomodoroTime / 60).floor().toString().padLeft(2, '0')}:${(pomodoroTime.remainder(60)).toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ))
              ]),
        ]));
  }
}

class GlassButton extends StatelessWidget {
  final String text;
  // final Function callbackFunction;
  final VoidCallback callbackFunction;
  static void defaultCallback() {
    print('Callback não definido.');
  }

  GlassButton({this.text: 'Jonas', this.callbackFunction: defaultCallback});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
        child: RaisedButton(
      elevation: 0,
      color: Colors.red[600],
      onPressed: callbackFunction,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red[400])),
      child: AutoSizeText(
        text,
        style: TextStyle(
            fontSize: 36, fontWeight: FontWeight.w300, color: Colors.black),
      ),
    ));
  }
}

class GlassPanel extends StatelessWidget {
  final bool bExpandAndCenter;
  final Widget child;
  GlassPanel(
      {this.bExpandAndCenter: true, this.child: const Text('Glass Panel')});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            blurRadius: 128,
            spreadRadius: 8,
            color: Colors.black.withOpacity(0.3))
      ]),
      // child: Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.15)
                    ],
                  ),
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      width: 2, color: Colors.white.withOpacity(0.2))),
              child: bExpandAndCenter
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: child,
                      ),
                    )
                  : Padding(padding: const EdgeInsets.all(8.0), child: child)),
        ),
      ),
      // ),
    );
  }
}
