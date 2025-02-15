import 'package:provider/provider.dart';
import '../models/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _gridSize = 4;
  final List<Color> _colors = [Colors.yellow, Colors.blue, Colors.green, Colors.red];
  final List<String> _colorLabels = ['Top\nLeft', 'Top\nRight', 'Bottom\nLeft', 'Bottom\nRight'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Grid Size'),
                  subtitle: CupertinoSlidingSegmentedControl<int>(
                    thumbColor: Colors.white10,
                    groupValue: _gridSize,
                    onValueChanged: (value) => setState(() => _gridSize = value!),
                    children: {for (int n = 4; n <= 10; n += 2) n: Text('${n}x$n')},
                  ),
                ),
                ListTile(
                  title: const Text('Colors'),
                  subtitle: LayoutBuilder(
                    builder: (context, box) => Wrap(
                      children: List<Widget>.generate(
                        _colors.length,
                        (i) => Padding(
                          padding: const EdgeInsets.all(10),
                          child: ColorButton(
                            label: _colorLabels[i],
                            color: _colors[i],
                            size: box.maxWidth / 8,
                            onTap: () async {
                              final pikedColor = await showDialog<Color>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Pick a Color'),
                                  content: Wrap(
                                    children: List<Widget>.generate(
                                      _colorOptions.length,
                                      (n) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ColorButton(
                                          color: _colorOptions[n],
                                          size: box.maxWidth / 8,
                                          onTap: () => Navigator.of(context).pop(_colorOptions[n]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              if (pikedColor == null) return;
                              _colors[i] = pikedColor;

                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.play_arrow),
            onPressed: () {
              Provider.of<GameProvider>(context, listen: false).initGame(
                topLeftColor: _colors[0],
                topRightColor: _colors[1],
                bottomLeftColor: _colors[2],
                bottomRightColor: _colors[3],
                size: Point<int>(_gridSize, _gridSize),
              );
              Navigator.of(context).pushNamed('/level');
            },
          ),
        ),
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton({
    super.key,
    required this.color,
    required this.size,
    required this.onTap,
    this.label,
  });

  final double size;
  final Color color;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Text(label ?? ''),
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

const _colorOptions = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
  Colors.pink,
  Colors.brown,
  Colors.grey,
  Colors.white,
];
