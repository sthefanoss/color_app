import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import 'pages/level.dart';
import 'models/game.dart';
import 'package:flutter/services.dart';
import 'pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle().copyWith(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent));
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<GameProvider>(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        //  color: Colors.purple,
        theme: ThemeData.dark(),
        routes: {
          '/': (ctx) => HomePage(),
          '/level': (ctx) => LevelPage(),
        },
      ),
    );
  }
}
