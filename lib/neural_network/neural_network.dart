import 'package:eneural_net/eneural_net.dart';
import 'package:flame/components.dart';
import 'dart:math';

class NeuralNetwork implements Comparable<NeuralNetwork> {
  bool won = false;
  int survivedTime = 0;
  /// 0.00 - 0.50 values are usually good
  late double impulse;
  final bool isRed;
  late var ann;

  NeuralNetwork(this.isRed, {var existing}) {
    if (isRed) {
      impulse = 0.8;
    } else {
      impulse = 1.6;
    }
    if (existing != null) {
      ann = existing;
      return;
    }
    ann = _buildDefaultANN();
  }


  static NeuralNetwork fromWeights(List<double> weights, bool isRed) {
    var ann = _buildDefaultANN();
    ann.allWeights = weights;
    return NeuralNetwork(isRed, existing: ann);
  }

  static dynamic _buildDefaultANN() {
    var scale = ScaleDouble.ZERO_TO_ONE;
    var activationFunction = ActivationFunctionSigmoid();
    return ANN(
      scale,
      LayerFloat32x4(10, true, ActivationFunctionLinear()),
      [
        HiddenLayerConfig(8, true, activationFunction),
      ],
      LayerFloat32x4(4, false, activationFunction),
    );
  }

  Vector2 getImpulse(
      {required double xDiffBall,
      required double yDiffBall,
      required double xDiffLeftWall,
      required double xDiffRightWall,
      required double yDiffTopWall,
      required double yDiffBottomWall,
      required double velocityHorizontal,
      required double velocityVertical,
      required double opponentVelocityHorizontal,
      required double opponentVelocityVertical}) {
    var signal = SampleFloat32x4.fromString(
        "$xDiffBall,$yDiffBall,"
        "$xDiffLeftWall,$xDiffRightWall,"
        "$yDiffTopWall,$yDiffBottomWall,"
        "$opponentVelocityHorizontal,$opponentVelocityVertical,"
        "$velocityHorizontal,$velocityVertical=1",
        ScaleDouble.ZERO_TO_ONE,
        true);
    ann.activate(signal.input);
    double horizontal = 0;
    double vertical = 0;
    if (ann.output[0] > 0.50) horizontal -= impulse;
    if (ann.output[1] > 0.50) horizontal += impulse;
    if (ann.output[2] > 0.50) vertical -= impulse;
    if (ann.output[3] > 0.50) vertical += impulse;
    return Vector2(horizontal, vertical);
  }

  NeuralNetwork child(NeuralNetwork other) {
    Random random = Random();
    var newAnn = _buildDefaultANN();
    List<double> mutatedWeights = [];
    for (int i = 0; i < ann.allWeights.length; i++) {
      if (random.nextDouble() > 0.50) {
        mutatedWeights.add(ann.allWeights[i]);
      } else {
        mutatedWeights.add(other.ann.allWeights[i]);
      }
    }
    newAnn.allWeights = mutatedWeights;
    return NeuralNetwork(isRed, existing: newAnn);
  }

  NeuralNetwork mutation() {
    Random random = Random();
    var newAnn = _buildDefaultANN();
    List<double> mutatedWeights = [];
    for (double weight in ann.allWeights) {
      if (random.nextDouble() > 0.9) {
        double mutation = weight - (random.nextDouble() - 0.5) / 2;
        mutatedWeights.add(mutation);
      } else {
        mutatedWeights.add(weight);
      }
    }
    newAnn.allWeights = mutatedWeights;
    return NeuralNetwork(isRed, existing: newAnn);
  }

  @override
  int compareTo(NeuralNetwork other) {
    if (won && !other.won) {
      return 1;
    }
    if (!won && other.won) {
      return -1;
    }
    if (won && other.won) {
      return 0;
    }
    if (survivedTime > other.survivedTime) {
      return 1;
    }
    return 0;
  }
}
