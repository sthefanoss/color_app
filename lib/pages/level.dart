import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'dart:async';
import '../widget/game_canvas.dart';
import 'package:flutter/services.dart';
import '../models/game.dart';
import 'package:provider/provider.dart';

class LevelPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
      color:
          Provider.of<GameProvider>(context, listen: false).darkBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 120),
        child: GameCanvas(),
      ),
    );
  }
}
