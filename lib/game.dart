import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:game_test/characters/blue_player.dart';
import 'package:game_test/evolution_algorithm/neural_network_manager.dart';
import 'package:game_test/neural_network/neural_network.dart';
import 'package:game_test/characters/contact_listener.dart';
import 'create_boundaries/boundaries.dart';
import 'characters/red_player.dart';
import 'dart:math';

class RedAndBlueGame extends Forge2DGame with KeyboardEvents {
  ContactListener? contactListener;
  bool gameGoing = true;
  RedPlayer? red;
  BluePlayer? blue;
  NeuralNetworkManager? nnManager;
  NeuralNetwork? blueNN;
  NeuralNetwork? redNN;
  Stopwatch stopwatch = Stopwatch();
  final int gameLengthInSeconds;
  List<Wall>? boundaries;

  RedAndBlueGame(
      this.redNN, this.blueNN, this.nnManager, this.gameLengthInSeconds);

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isUp = keysPressed.contains(LogicalKeyboardKey.arrowUp);
    final isDown = keysPressed.contains(LogicalKeyboardKey.arrowDown);
    final isRight = keysPressed.contains(LogicalKeyboardKey.arrowRight);
    double impulse = 2;
    if (isLeft) {
      if (blueNN == null) {
        blue!.applyLinearImpulse(Vector2(-impulse, 0));
      }
      if (redNN == null) {
        red!.applyLinearImpulse(Vector2(-impulse, 0));
      }
      return KeyEventResult.handled;
    }
    if (isUp) {
      if (blueNN == null) {
        blue!.applyLinearImpulse(Vector2(0, -impulse));
      }
      if (redNN == null) {
        red!.applyLinearImpulse(Vector2(0, -impulse));
      }
      return KeyEventResult.handled;
    }
    if (isDown) {
      if (blueNN == null) {
        blue!.applyLinearImpulse(Vector2(0, impulse));
      }
      if (redNN == null) {
        red!.applyLinearImpulse(Vector2(0, impulse));
      }
      return KeyEventResult.handled;
    }
    if (isRight) {
      if (blueNN == null) {
        blue!.applyLinearImpulse(Vector2(1, 0));
      }
      if (redNN == null) {
        red!.applyLinearImpulse(Vector2(1, 0));
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void update(double dt) {
    if (!gameGoing) {
      return;
    }
    if (stopwatch.elapsedMilliseconds >= gameLengthInSeconds * 1000) {
      blueWon();
      return;
    }
    if (blueNN != null) blue!.applyLinearImpulse(_getBlueImpulse());
    if (redNN != null) red!.applyLinearImpulse(_getRedImpulse());
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    world.setGravity(Vector2(0, 0));
    _addBoundaries();
    List<Vector2> positions = _getRandomStartingPositions();
    red = RedPlayer(positions[0], _getGameAreaHeight() / 15);
    blue = BluePlayer(positions[1], _getGameAreaHeight() / 15);
    add(red!);
    add(blue!);
    if (redNN != null && blueNN != null) {
      contactListener = GameContactListener(this);
      world.setContactListener(contactListener!);
    }
    stopwatch.start();
  }

  List<Vector2> _getRandomStartingPositions() {
    Random random = Random();
    int redPosition = random.nextInt(8);
    int bluePosition = random.nextInt(8);
    while (redPosition == bluePosition) {
      bluePosition = random.nextInt(8);
    }
    return [
      _getStartingPosition(redPosition),
      _getStartingPosition(bluePosition)
    ];
  }

  double _getGameAreaHeight() {
    final topLeft = Vector2.zero();
    final bottomRight = screenToWorld(camera.viewport.effectiveSize);
    return bottomRight.y - topLeft.y;
  }

  double _getGameAreaWidth() {
    final topLeft = Vector2.zero();
    final bottomRight = screenToWorld(camera.viewport.effectiveSize);
    return topLeft.x - bottomRight.x;
  }

  Vector2 _getStartingPosition(int position) {
    final worldCenter = screenToWorld(size * camera.zoom / 2);
    double height = _getGameAreaHeight();
    double width = _getGameAreaWidth();
    switch (position) {
      case 0:
        return Vector2(worldCenter.x - width / 3, worldCenter.y - height / 3);
      case 1:
        return Vector2(worldCenter.x, worldCenter.y - height / 3);
      case 2:
        return Vector2(worldCenter.x + width / 3, worldCenter.y - height / 3);
      case 3:
        return Vector2(worldCenter.x + width / 3, worldCenter.y);
      case 4:
        return Vector2(worldCenter.x + width / 3, worldCenter.y + height / 3);
      case 5:
        return Vector2(worldCenter.x, worldCenter.y + height / 3);
      case 6:
        return Vector2(worldCenter.x - width / 3, worldCenter.y + height / 3);
      case 7:
        return Vector2(worldCenter.x - width / 3, worldCenter.y);
    }
    throw Exception("Position not defined");
  }

  Vector2 _getRedImpulse() {
    final topLeft = Vector2.zero();
    final bottomRight = screenToWorld(camera.viewport.effectiveSize);
    return redNN!.getImpulse(
        xDiffBall: red!.center.x - blue!.center.x,
        yDiffBall: red!.center.y - blue!.center.y,
        xDiffLeftWall: topLeft.x - red!.center.x,
        xDiffRightWall: bottomRight.x - red!.center.x,
        yDiffTopWall: topLeft.y - red!.center.y,
        yDiffBottomWall: bottomRight.y - red!.center.y,
        velocityHorizontal: red!.body.linearVelocity.x,
        velocityVertical: red!.body.linearVelocity.y,
        opponentVelocityHorizontal: blue!.body.linearVelocity.x,
        opponentVelocityVertical: blue!.body.linearVelocity.y);
  }

  Vector2 _getBlueImpulse() {
    final topLeft = Vector2.zero();
    final bottomRight = screenToWorld(camera.viewport.effectiveSize);
    return blueNN!.getImpulse(
        xDiffBall: red!.center.x - blue!.center.x,
        yDiffBall: red!.center.y - blue!.center.y,
        xDiffLeftWall: topLeft.x - blue!.center.x,
        xDiffRightWall: bottomRight.x - blue!.center.x,
        yDiffTopWall: topLeft.y - blue!.center.y,
        yDiffBottomWall: bottomRight.y - blue!.center.y,
        velocityHorizontal: blue!.body.linearVelocity.x,
        velocityVertical: blue!.body.linearVelocity.y,
        opponentVelocityHorizontal: red!.body.linearVelocity.x,
        opponentVelocityVertical: red!.body.linearVelocity.y);
  }

  void _addBoundaries() {
    boundaries = createBoundaries(this);
    boundaries!.forEach(add);
  }

  void redWon() {
    blue!.paint.color = Colors.red;
    blueNN?.won = false;
    redNN?.won = true;
    _gameEnded();
  }

  void blueWon() {
    blueNN?.won = true;
    redNN?.won = false;
    _gameEnded();
  }

  void _gameEnded() {
    blueNN?.survivedTime = stopwatch.elapsedMilliseconds;
    gameGoing = false;
    nnManager?.gameEnded();
  }
}
