import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_test/characters/red_player.dart';
import '../game.dart';
import 'blue_player.dart';

class GameContactListener extends ContactListener {
  RedAndBlueGame game;

  GameContactListener(this.game);

  @override
  void beginContact(Contact contact) {
    if (contact.bodyA.userData is RedPlayer &&
            contact.bodyB.userData is BluePlayer ||
        contact.bodyB.userData is RedPlayer &&
            contact.bodyA.userData is BluePlayer) {
      game.redWon();
    }
  }

  @override
  void endContact(Contact contact) {}

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}
}
