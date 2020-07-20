import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/game.dart';
import 'dart:math';

class GameCanvas extends StatefulWidget {
  @override
  _GameCanvasState createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas>
    with SingleTickerProviderStateMixin {
  AnimationController _tileController;
  Animation<Offset> _selectedTileAnimation;
  Animation<Offset> _swappedTileAnimation;
  Animation<double> _tileDisappearAnimation;
  Offset _selectedTilePanOffset;
  bool _init = true, _disappearAnimationHalfCompleted = false;

  @override
  void dispose() {
    _tileController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_init) {
      _init = false;
      _tileController = AnimationController(
          duration: const Duration(milliseconds: 500), vsync: this);
      final listener = () {
        setState(() {});
      };
      AnimationStatusListener statusListener;
      statusListener = (status) {
        if (status == AnimationStatus.completed) {
          if (!_disappearAnimationHalfCompleted) {
            setState(() {
              _disappearAnimationHalfCompleted = true;
            });
            _tileController.reverse();
          }
        } else if (status == AnimationStatus.dismissed) {
          Provider.of<GameProvider>(context, listen: false).runGame();
          _tileController.duration = Duration(milliseconds: 100);
          _tileDisappearAnimation.removeListener(listener);
          _tileDisappearAnimation.removeStatusListener(statusListener);
          _tileDisappearAnimation = null;
        }
      };
      Timer(Duration(seconds: 1), () {
        _tileDisappearAnimation =
            Tween<double>(begin: 1, end: 0).animate(_tileController)
              ..addListener(listener)
              ..addStatusListener(statusListener);
        _tileController.forward();
//        setState(() {});
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    return LayoutBuilder(
      builder: (context, box) {
        final tileSize =
            Size(box.maxWidth / game.size.x, box.maxHeight / game.size.y);
        return GestureDetector(
          onPanStart: (details) {
            if (!(game.gameState == GameState.Running)) return;
            if (game.selectedTileState == SelectedTileState.Awaiting) {
              final position = Point<int>(
                  (details.localPosition.dx / tileSize.width).truncate(),
                  (details.localPosition.dy / tileSize.height).truncate());
              game.panSelectTile(position);
              if (game.selectedTileState == SelectedTileState.Panning)
                setState(() {
                  _selectedTilePanOffset = details.localPosition;
                });
            }
          },
          onPanUpdate: (details) {
            if (!(game.gameState == GameState.Running)) return;
            if (game.selectedTileState == SelectedTileState.Panning)
              setState(() {
                _selectedTilePanOffset = details.localPosition;
              });
          },
          onPanEnd: (_) {
            if (!(game.gameState == GameState.Running)) return;
            if (game.selectedTileState == SelectedTileState.Panning)
              setState(() {
                final position = Point<int>(
                    (_selectedTilePanOffset.dx / tileSize.width).truncate(),
                    (_selectedTilePanOffset.dy / tileSize.height).truncate());
                game.dropTile(position);
                if (game.selectedTileState == SelectedTileState.DroppedWrong) {
                  _selectedTileAnimation = Tween<Offset>(
                          begin: _selectedTilePanOffset,
                          end: tileCenter(game.selectedTile.key, tileSize))
                      .animate(_tileController);
                  Function listener = () {
                    setState(() {});
                  };
                  AnimationStatusListener statusListener;
                  statusListener = (AnimationStatus status) {
                    if (status == AnimationStatus.completed) {
                      setState(() {
                        _selectedTilePanOffset = null;
                        game.dropTileComplete();
                        _tileController.reset();
                        _selectedTileAnimation
                            .removeStatusListener(statusListener);
                        _selectedTileAnimation.removeListener(listener);
                        _selectedTileAnimation = null;
                      });
                    }
                  };
                  _selectedTileAnimation
                    ..addStatusListener(statusListener)
                    ..addListener(listener);

                  _tileController.forward();
                } else if (game.selectedTileState ==
                    SelectedTileState.DroppedRight) {
                  _selectedTileAnimation = Tween<Offset>(
                          begin: _selectedTilePanOffset,
                          end: tileCenter(game.swappedTile.key, tileSize))
                      .animate(_tileController);
                  _swappedTileAnimation = Tween<Offset>(
                          begin: Offset.lerp(
                              tileCenter(game.swappedTile.key, tileSize),
                              tileCenter(game.selectedTile.key, tileSize),
                              (tileCenter(game.swappedTile.key, tileSize) -
                                          tileCenter(
                                              game.selectedTile.key, tileSize))
                                      .distance
                                      .abs() /
                                  Offset(box.maxHeight, box.maxWidth).distance),
                          end: tileCenter(game.selectedTile.key, tileSize))
                      .animate(_tileController);
                  Function listener = () {
                    setState(() {});
                  };
                  AnimationStatusListener statusListener;
                  statusListener = (AnimationStatus status) {
                    if (status == AnimationStatus.completed) {
                      setState(() {
                        _selectedTilePanOffset = null;
                        game.dropTileComplete();
                        _tileController.reset();
                        _selectedTileAnimation
                            .removeStatusListener(statusListener);
                        _selectedTileAnimation.removeListener(listener);
                        _selectedTileAnimation = null;
                        _swappedTileAnimation = null;
                        if (game.gameState == GameState.Ended) {
                          _tileDisappearAnimation = Tween<double>(
                                  begin: 1, end: 0)
                              .animate(_tileController)
                                ..addListener(() => setState(() {}))
                                ..addStatusListener((status) {
                                  if (status == AnimationStatus.completed)
                                    _tileController.reverse();
                                  else if (status == AnimationStatus.dismissed)
                                    _tileController.forward();
                                });
                          _tileController.duration = Duration(seconds: 1);
                          _tileController.forward();
                        }
                      });
                    }
                  };
                  _selectedTileAnimation
                    ..addStatusListener(statusListener)
                    ..addListener(listener);
                  _tileController.forward();
                }
              });
          },
          child: SizedBox(
            width: box.maxWidth,
            height: box.maxHeight,
            child: CustomPaint(
              painter: _GamePainter(
                  tileSize: tileSize,
                  selectedTile: game.selectedTile,
                  swappedTile: game.swappedTile,
                  selectedTileOffset: _selectedTileAnimation == null
                      ? _selectedTilePanOffset
                      : _selectedTileAnimation.value,
                  swappedTileOffset: _swappedTileAnimation == null
                      ? null
                      : _swappedTileAnimation.value,
                  darkBackgroundColor: game.darkBackgroundColor,
                  backgroundColor: game.backgroundColor,
                  movableTiles: game.movableTiles,
                  fixedTiles: game.fixedTiles,
                  gameState: game.gameState,
                  animationValue: _tileDisappearAnimation == null
                      ? 1
                      : pow(_tileDisappearAnimation.value, 2),
                  answerTiles: game.answerTiles,
                  shuffleAnimationHalfCompleted:
                      _disappearAnimationHalfCompleted),
            ),
          ),
        );
      },
    );
  }
}

class _GamePainter extends CustomPainter {
  const _GamePainter(
      {this.movableTiles,
      this.fixedTiles,
      this.selectedTile,
      this.swappedTile,
      this.tileSize,
      this.selectedTileOffset,
      this.swappedTileOffset,
      this.backgroundColor,
      this.darkBackgroundColor,
      this.gameState,
      this.animationValue,
      this.answerTiles,
      this.shuffleAnimationHalfCompleted});

  final Map<Point<int>, Color> movableTiles;
  final Map<Point<int>, Color> answerTiles;
  final Map<Point<int>, Color> fixedTiles;
  final MapEntry<Point<int>, Color> selectedTile;
  final MapEntry<Point<int>, Color> swappedTile;
  final Size tileSize;
  final Offset selectedTileOffset, swappedTileOffset;
  final Color backgroundColor;
  final Color darkBackgroundColor;
  final GameState gameState;
  final double animationValue;
  final bool shuffleAnimationHalfCompleted;

  @override
  void paint(Canvas canvas, Size size) {
    print(gameState);
    switch (gameState) {
      case GameState.Starting:
        {
          (shuffleAnimationHalfCompleted ? movableTiles : answerTiles).forEach(
              (key, value) => canvas.drawRect(
                  Rect.fromCenter(
                      center: tileCenter(key, tileSize),
                      width: tileSize.width * animationValue,
                      height: tileSize.height * animationValue),
                  Paint()..color = value));
          fixedTiles.forEach((key, value) {
            canvas.drawRect(
                Rect.fromCenter(
                    center: tileCenter(key, tileSize),
                    width: tileSize.width * animationValue,
                    height: tileSize.height * animationValue),
                Paint()..color = value);
            if (shuffleAnimationHalfCompleted)
              canvas.drawCircle(
                  tileCenter(key, tileSize),
                  5*animationValue,
                  Paint()
                    ..color = darkBackgroundColor);
          });
          break;
        }
      case GameState.Running:
        canvas.drawRect(Rect.fromLTRB(1, 1, size.width - 1, size.height - 1),
            Paint()..color = backgroundColor);
        if (swappedTile != null) {
          drawDarkTile(canvas, swappedTile.key);
          drawDarkTile(canvas, selectedTile.key);
          drawTileFromOffset(canvas, swappedTileOffset, swappedTile.value);
        }
        ({...movableTiles, ...fixedTiles})
            .forEach((key, value) => drawTileFromKey(canvas, key, value));
        fixedTiles.forEach((key, value) => canvas.drawCircle(
            tileCenter(key, tileSize),
            5,
            Paint()..color = darkBackgroundColor));
        if (selectedTile != null) {
          if (swappedTile == null) drawDarkTile(canvas, selectedTile.key);
          drawTileFromOffset(
              canvas,
              selectedTileOffset ?? tileCenter(selectedTile.key, tileSize),
              selectedTile.value,
              true);
        }
        break;
      case GameState.Ended:
        {
          ({...movableTiles, ...fixedTiles}).forEach((key, value) =>
              canvas.drawRect(
                  Rect.fromCenter(
                      center: tileCenter(key, tileSize),
                      width: tileSize.width * animationValue,
                      height: tileSize.height * animationValue),
                  Paint()..color = value));
          fixedTiles.forEach((key, value) => canvas.drawCircle(
              tileCenter(key, tileSize),
              5*animationValue,
              Paint()
                ..color = darkBackgroundColor));
          break;
        }
    }
  }

  @override
  bool shouldRepaint(_GamePainter oldDelegate) => false;

  void drawTileFromKey(Canvas canvas, Point<int> key, Color value) =>
      canvas.drawRect(
        Rect.fromLTRB(key.x * tileSize.width, key.y * tileSize.height,
            (key.x + 1) * tileSize.width, (key.y + 1) * tileSize.height),
        Paint()..color = value,
      );

  void drawTileFromOffset(Canvas canvas, Offset offset, Color value,
          [bool isSelected = false]) =>
      canvas.drawRect(
        isSelected
            ? Rect.fromLTRB(
                offset.dx - tileSize.width / 1.8,
                offset.dy - tileSize.height / 1.8,
                offset.dx + tileSize.width / 1.8,
                offset.dy + tileSize.height / 1.8)
            : Rect.fromLTRB(
                offset.dx - tileSize.width / 2,
                offset.dy - tileSize.height / 2,
                offset.dx + tileSize.width / 2,
                offset.dy + tileSize.height / 2),
        Paint()..color = value,
      );

  void drawDarkTile(Canvas canvas, Point<int> key) => canvas.drawRect(
        Rect.fromLTRB(key.x * tileSize.width, key.y * tileSize.height,
            (key.x + 1) * tileSize.width, (key.y + 1) * tileSize.height),
        Paint()..color = darkBackgroundColor,
      );
}

Offset tileCenter(Point<int> position, Size tileSize) => Offset(
    (position.x + 0.5) * tileSize.width, (position.y + 0.5) * tileSize.height);
