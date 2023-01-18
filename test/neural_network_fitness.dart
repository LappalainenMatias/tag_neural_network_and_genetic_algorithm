import 'package:flutter_test/flutter_test.dart';
import 'package:game_test/neural_network/neural_network.dart';

void main() {
  test('sort list of neural networks', () {
    var n1 = NeuralNetwork(true);
    n1.won = true;
    n1.survivedTime = 0;
    var n2 = NeuralNetwork(true);
    n2.won = true;
    n2.survivedTime = 1;
    var n3 = NeuralNetwork(true);
    n3.won = false;
    n3.survivedTime = 3;
    var n4 = NeuralNetwork(true);
    n4.won = false;
    n4.survivedTime = 2;
    var n5 = NeuralNetwork(true);
    n5.won = false;
    n5.survivedTime = 4;
    var unsortedList = [n2, n1, n5, n3, n4];

    unsortedList.sort();

    var expectedSortedList = [n4, n3, n5, n2, n1];

    expect(unsortedList, expectedSortedList);
  });
}
