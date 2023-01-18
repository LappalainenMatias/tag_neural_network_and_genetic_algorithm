import 'package:flame/game.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class SmallRedCircle extends BodyComponent {
  Vector2 position;


  SmallRedCircle(this.position);

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = 3;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.8,
      density: 0.5,
      friction: 0.2,
    );

    final bodyDef = BodyDef(
      userData: this,
      angularDamping: 0.8,
      position: position,
      type: BodyType.dynamic,
    );

    paint.color = Colors.red;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}