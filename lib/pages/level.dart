import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widget/game_canvas.dart';
import '../models/game.dart';
import 'package:provider/provider.dart';

class LevelPage extends StatelessWidget {
  const LevelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          Provider.of<GameProvider>(context, listen: false).darkBackgroundColor,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 120),
        child: GameCanvas(),
      ),
    );
  }
}
