import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/level.dart';
import 'models/game.dart';
import 'package:flutter/services.dart';
import 'pages/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle().copyWith(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ));
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

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
          '/': (ctx) => const HomePage(),
          '/level': (ctx) => const LevelPage(),
        },
      ),
    );
  }
}
