import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GameDifficulty _gameDifficulty = GameDifficulty.Easy;
  int _gridSize = 3;
  NumberOfFixedTiles _numberOfFixedTiles = NumberOfFixedTiles.Medium;
  List<Color> _colors = [Colors.yellow, Colors.blue, Colors.green, Colors.red];
  List<String> _colorLabels = [
    'Top\nLeft',
    'Top\nRight',
    'Bottom\nLeft',
    'Bottom\nRight'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text('Difficulty'),
                  subtitle: CupertinoSlidingSegmentedControl<GameDifficulty>(
                    thumbColor: Colors.white10,
                    groupValue: _gameDifficulty,
                    onValueChanged: (value) =>
                        setState(() => _gameDifficulty = value),
                    children: {
                      GameDifficulty.Easy: Text('Easy'),
                      GameDifficulty.Medium: Text('Medium'),
                      GameDifficulty.Hard: Text('Hard'),
                    },
                  ),
                ),
                ListTile(
                  title: Text('Grid Size'),
                  subtitle: CupertinoSlidingSegmentedControl<int>(
                    thumbColor: Colors.white10,
                    groupValue: _gridSize,
                    onValueChanged: (value) =>
                        setState(() => _gridSize = value),
                    children: {for (int n = 2; n < 11; n++) n: Text('${n}x$n')},
                  ),
                ),
                ListTile(
                  title: Text('Number of Fixed Points'),
                  subtitle:
                      CupertinoSlidingSegmentedControl<NumberOfFixedTiles>(
                    thumbColor: Colors.white10,
                    groupValue: _numberOfFixedTiles,
                    onValueChanged: (value) =>
                        setState(() => _numberOfFixedTiles = value),
                    children: {
                      NumberOfFixedTiles.Few: Text('Few'),
                      NumberOfFixedTiles.Medium: Text('Medium'),
                      NumberOfFixedTiles.Good: Text('Good'),
                    },
                  ),
                ),
                ListTile(
                  title: Text('Colors'),
                  subtitle: LayoutBuilder(
                    builder: (context, box) => Wrap(
                        children: List<Widget>.generate(
                            _colors.length,
                            (n) => Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ColorButton(
                                      label: _colorLabels[n],
                                      color: _colors[n],
                                      size: box.maxWidth / 8,
                                      onTap: () async {
                                        final pikedColor = await showDialog<
                                                Color>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                title: Text('Pick a Color'),
                                                content: Wrap(
                                                  children:
                                                      List<Widget>.generate(
                                                    _colorsByDifficulty[
                                                            _gameDifficulty]
                                                        .length,
                                                    (n) => Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: ColorButton(
                                                        color: _colorsByDifficulty[
                                                            _gameDifficulty][n],
                                                        size: box.maxWidth / 8,
                                                        onTap: () => Navigator
                                                                .of(context)
                                                            .pop(_colorsByDifficulty[
                                                                    _gameDifficulty]
                                                                [n]),
                                                      ),
                                                    ),
                                                  ),
                                                )));
                                        if (pikedColor == null) return;
                                        final savedColor = _colors[n];
                                        _colors[n] = pikedColor;
                                        if (_colors[0] == _colors[1] &&
                                            _colors[0] == _colors[2] &&
                                            _colors[0] == _colors[3])
                                          _colors[n] = savedColor;
                                        setState(() {});
                                      }),
                                ))),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () {
              Provider.of<GameProvider>(context, listen: false).initGame(
                  topLeftColor: _colors[0],
                  topRightColor: _colors[1],
                  bottomLeftColor: _colors[2],
                  bottomRightColor: _colors[3],
                  size: Point<int>(_gridSize, _gridSize),
                  numberOfFixedTiles: _numberOfFixedTiles);
              Navigator.of(context).pushNamed('/level');
            },
          ),
        ),
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton({this.color, this.size, this.onTap, this.label});
  final double size;
  final Color color;
  final String label;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          if (label != null) Text(label),
          Card(
            clipBehavior: Clip.hardEdge,
            child: Container(
              width: size,
              height: size,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

const Map<GameDifficulty, List<Color>> _colorsByDifficulty = {
  GameDifficulty.Easy: [
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
  ],
  GameDifficulty.Medium: [
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
    Colors.redAccent,
    Colors.orange,
    Colors.yellow,
    Colors.yellowAccent,
  ],
  GameDifficulty.Hard: [
    Colors.deepPurpleAccent,
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
    Colors.pinkAccent,
    Colors.redAccent,
    Colors.red,
    Colors.orange,
    Colors.orangeAccent,
    Colors.amber,
    Colors.amberAccent,
    Colors.yellow,
    Colors.yellowAccent,
  ]
};
