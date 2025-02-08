import 'package:flutter/material.dart';
import 'dart:math';

enum GameState { Starting, Running, Ended }

enum SelectedTileState {
  Awaiting,
  Panning,
  DroppedWrong,
  DroppedRight,
}

class GameProvider {
  void initGame({
    required Color topLeftColor,
    required Color topRightColor,
    required Color bottomLeftColor,
    required Color bottomRightColor,
    Point<int> size = const Point<int>(10, 10),
  }) {
    final fixedPoints = [
      Point<int>(0, 0),
      Point<int>(size.x - 1, 0),
      Point<int>(0, size.y - 1),
      Point<int>(size.x - 1, size.y - 1),
    ];
    _answerTiles = {};
    _fixedTiles = {};
    _movableTiles = {};
    _size = size;
    _backgroundColor = _dualLerp(topLeftColor, topRightColor, bottomLeftColor, bottomRightColor, 0.5, 0.5);
    _darkBackgroundColor = Color.lerp(_backgroundColor, Colors.black, 0.8)!.withOpacity(1);

    for (int y = 0; y < size.y; y++) {
      for (int x = 0; x < size.x; x++) {
        final position = Point<int>(x, y);
        final color = _dualLerp(
            topLeftColor, topRightColor, bottomLeftColor, bottomRightColor, x / (size.x - 1), y / (size.y - 1));
        if (fixedPoints.contains(position)) {
          _fixedTiles[position] = color;
        } else {
          _movableTiles[position] = color;
          _answerTiles[position] = color;
        }
      }
    }
    _shuffle();
    _selectedTile = null;
    _swappedTile = null;
    _gameState = GameState.Starting;
    _selectedTileState = SelectedTileState.Awaiting;
  }

  void runGame() {
    if (_gameState != GameState.Starting) return;
    _gameState = GameState.Running;
  }

  void _shuffle() {
    final random = Random();
    _movableTiles.forEach((key, value) {
      final randomKey = _movableTiles.keys.toList()[random.nextInt(_movableTiles.keys.toList().length - 1)];
      final color = value;
      _movableTiles[key] = _movableTiles[randomKey]!;
      _movableTiles[randomKey] = color;
    });
  }

  void panSelectTile(Point<int> key) {
    if (_movableTiles.containsKey(key)) {
      _selectedTile = MapEntry(key, _movableTiles.remove(key)!);
      _selectedTileState = SelectedTileState.Panning;
    } else {
      _selectedTileState = SelectedTileState.Awaiting;
    }
  }

  void dropTile(Point<int> key) {
    if (_movableTiles.containsKey(key)) {
      _swappedTile = MapEntry(key, _movableTiles.remove(key)!);
      _selectedTileState = SelectedTileState.DroppedRight;
    } else {
      _selectedTileState = SelectedTileState.DroppedWrong;
    }
  }

  void dropTileComplete() {
    switch (_selectedTileState) {
      case SelectedTileState.DroppedRight:
        {
          _movableTiles[_selectedTile!.key] = _swappedTile!.value;
          _movableTiles[_swappedTile!.key] = _selectedTile!.value;
          _selectedTile = null;
          _swappedTile = null;
          _selectedTileState = SelectedTileState.Awaiting;
          if (endGame) _gameState = GameState.Ended;
          break;
        }
      case SelectedTileState.DroppedWrong:
        {
          _movableTiles[_selectedTile!.key] = _selectedTile!.value;
          _selectedTile = null;
          _selectedTileState = SelectedTileState.Awaiting;
          break;
        }
      case SelectedTileState.Panning:
      case SelectedTileState.Awaiting:
      default:
        break;
    }
  }

  late SelectedTileState _selectedTileState;
  get selectedTileState => _selectedTileState;

  late GameState _gameState;
  get gameState => _gameState;

  Map<Point<int>, Color> _movableTiles = {};
  get movableTiles => {..._movableTiles};

  Map<Point<int>, Color> _fixedTiles = {};
  get fixedTiles => {..._fixedTiles};

  Map<Point<int>, Color> _answerTiles = {};
  get answerTiles => {..._answerTiles};

  late Color _backgroundColor;
  get backgroundColor => _backgroundColor;

  late Color _darkBackgroundColor;
  get darkBackgroundColor => _darkBackgroundColor;

  late Point<int> _size;
  get size => Point(_size.x, _size.y);

  MapEntry<Point<int>, Color>? _selectedTile;
  get selectedTile => _selectedTile != null ? MapEntry(_selectedTile!.key, _selectedTile!.value) : null;

  MapEntry<Point<int>, Color>? _swappedTile;
  get swappedTile => _swappedTile != null ? MapEntry(_swappedTile!.key, _swappedTile!.value) : null;

  Map<Point<int>, Color> get allTiles => {..._movableTiles, ..._fixedTiles};

  bool get endGame {
    for (final key in _answerTiles.keys.toList()) {
      if (_answerTiles[key] != _movableTiles[key]) return false;
    }
    return true;
  }
}

Color _dualLerp(
  Color topLeftColor,
  Color topRightColor,
  Color bottomLeftColor,
  Color bottomRightColor,
  double x,
  double y,
) =>
    Color.lerp(
      Color.lerp(topLeftColor, topRightColor, x)!,
      Color.lerp(bottomLeftColor, bottomRightColor, x)!,
      y,
    )!;
