import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../neural_network/neural_network.dart';

class NeuralNetworkManager with ChangeNotifier {
  int redWinPercentage = 0;
  int generationIndex = 0;
  int generationSize = 250;
  List<NeuralNetwork> reds = [];
  List<NeuralNetwork> blues = [];
  int gamesInProgress = 0;

  NeuralNetworkManager() {
    for (int i = 0; i < generationSize; i++) {
      reds.add(NeuralNetwork(true));
      blues.add(NeuralNetwork(false));
    }
  }

  void _generateNewGeneration() {
    int redWins = 0;
    for (NeuralNetwork redNN in reds) {
      if (redNN.won) redWins++;
    }
    redWinPercentage = (redWins / generationSize * 100).round();
    generationIndex += 1;
    print("generation $generationIndex: $redWinPercentage");
    Random random = Random();
    reds.sort((a, b) => b.compareTo(a));
    blues.sort((a, b) => b.compareTo(a));
    //print(reds.first.ann.allWeights);
    //print(blues.first.ann.allWeights);
    //print("${blues.first.survivedTime} ${blues.first.won}");
    reds = reds.sublist(0, (generationSize / 2).round());
    blues = blues.sublist(0, (generationSize / 2).round());
    List<NeuralNetwork> redChildrenAndMutations = [];
    List<NeuralNetwork> blueChildrenAndMutations = [];
    while (redChildrenAndMutations.length + reds.length < generationSize) {
      if (random.nextDouble() > 0.50) {
        redChildrenAndMutations.add(_createChildren(reds));
      } else {
        redChildrenAndMutations.add(_createMutation(reds));
      }
    }
    while (blueChildrenAndMutations.length + blues.length < generationSize) {
      if (random.nextDouble() > 0.50) {
        blueChildrenAndMutations.add(_createChildren(blues));
      } else {
        blueChildrenAndMutations.add(_createMutation(blues));
      }
    }
    reds.addAll(redChildrenAndMutations);
    blues.addAll(blueChildrenAndMutations);
    for(var red in reds) {
      red.won = false;
    }
    for(var blue in blues) {
      blue.won = false;
    }
    notifyListeners();
  }

  NeuralNetwork _createChildren(List<NeuralNetwork> nns) {
    Random random = Random();
    int a = random.nextInt(nns.length);
    int b = random.nextInt(nns.length);
    return nns[a].child(nns[b]);
  }

  NeuralNetwork _createMutation(List<NeuralNetwork> nns) {
    Random random = Random();
    int a = random.nextInt(nns.length);
    return nns[a].mutation();
  }

  List<List<NeuralNetwork>> getGames() {
    gamesInProgress = generationSize;
    List<List<NeuralNetwork>> games = [];
    for (int i = 0; i < generationSize; i++) {
      games.add([reds[i],blues[i]]);
    }
    return games;
  }

  void gameEnded() {
    gamesInProgress -= 1;
    if (gamesInProgress == 0) {
      _generateNewGeneration();
    }
  }
}
