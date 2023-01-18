import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class RedPlayer extends BodyComponent {
  final Vector2 _startingPosition;
  final double _radius;

  RedPlayer(this._startingPosition, this._radius);

  void applyLinearImpulse(Vector2 impulse) {
    impulse = impulse * body.mass; // This fixes some issues with scaling
    Vector2 newVelocity = Vector2(0,0);
    newVelocity.add(body.linearVelocity);
    newVelocity.add(impulse);
    if (newVelocity.length >= 2 * body.mass) return;
    body.applyLinearImpulse(impulse);
  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = _radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.8,
      density: 1.0,
      friction: 0.1,
    );

    final bodyDef = BodyDef(
      userData: this,
      angularDamping: 0.8,
      position: _startingPosition,
      type: BodyType.dynamic,
    );

    paint.color = Colors.red;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
