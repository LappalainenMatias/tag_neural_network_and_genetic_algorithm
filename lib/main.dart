import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:game_test/evolution_algorithm/neural_network_manager.dart';
import 'package:game_test/neural_network/neural_network.dart';
import 'package:provider/provider.dart';
import 'game.dart';
import 'data.dart' as weights;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NeuralNetworkManager()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Red and blue game',
      home: Scaffold(
        body: PlayAgainstMachine(playAsRed: false,),
      ),
    );
  }
}

class PlayAgainstMachine extends StatefulWidget {
  final bool playAsRed;

  const PlayAgainstMachine({super.key, required this.playAsRed});

  @override
  State<PlayAgainstMachine> createState() => _PlayAgainstMachineState();
}

class _PlayAgainstMachineState extends State<PlayAgainstMachine> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          child: GameWidget(
            game: RedAndBlueGame(
                widget.playAsRed
                    ? null
                    : NeuralNetwork.fromWeights(weights.blueWeights, true),
                widget.playAsRed
                    ? NeuralNetwork.fromWeights(weights.redWeights, false)
                    : null,
                null,
                600),
          ),
        ),
      ],
    );
  }
}

class Simulation extends StatefulWidget {
  const Simulation({super.key});

  @override
  State<Simulation> createState() => _SimulationState();
}

class _SimulationState extends State<Simulation> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NeuralNetworkManager>(builder: (context, nnManager, child) {
      return Column(
        children: [
          Text(
              "generation size: ${nnManager.generationSize}, generation: ${nnManager.generationIndex}, red win percentage: ${nnManager.redWinPercentage} %"),
          GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.all(1),
              crossAxisCount: 10,
              children: _buildGames(nnManager)),
        ],
      );
    });
  }

  List<Widget> _buildGames(NeuralNetworkManager nnManager) {
    List<Widget> widgets = [];
    for (List<NeuralNetwork> players in nnManager.getGames()) {
      widgets.add(
        Container(
          padding: const EdgeInsets.all(4),
          child: GameWidget(
            game: RedAndBlueGame(players[0], players[1], nnManager, 15),
          ),
        ),
      );
    }
    return widgets;
  }
}
