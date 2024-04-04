import 'dart:math';

import 'package:lunch_roulette/main.dart';
import 'package:roulette/roulette.dart';
import 'package:flutter/material.dart';

import 'controls/arrow.dart';

class MyRoulette extends StatelessWidget {
  const MyRoulette({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final RouletteController controller;
  //late MyAppState state;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: 480,
          height: 480,
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Roulette(
              // Provide controller to update its state
              controller: controller,
              // Configure roulette's appearance
              style: const RouletteStyle(
                dividerThickness: 4,
                textLayoutBias: .8,
                centerStickerColor: Color(0xFF45A3FA),
              ),
            ),
          ),
        ),
        const Arrow(),
      ],
    );
  }
}

class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage>
    with SingleTickerProviderStateMixin {
  static final _random = Random();

  late RouletteController _controller;
  int rouletteIndex = 0;

  @override
  void initState() {
    // Initialize the controller

    final group = RouletteGroup.uniform(
      MyApp.colors.length,
      textBuilder: MyApp.texts.elementAt,
      colorBuilder: MyApp.colors.elementAt,
      textStyleBuilder: (index) => const TextStyle(
        color: Colors.black,
      ),
    );

    _controller = RouletteController(vsync: this, group: group);

    _controller.animation.addStatusListener((status) {
      if (status.name == "completed") {
        debugPrint(_controller.animation.value.toString());
      }
      debugPrint('updated!!!! ${status.name}');
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "오늘의 점심",
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              MyRoulette(controller: _controller),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Use the controller to run the animation with rollTo method
        onPressed: () => {
          rouletteIndex = _random.nextInt(_controller.group.units.length),
          _controller.rollTo(
            _random.nextInt(_controller.group.units.length),
            offset: _random.nextDouble(),
          ),
        },
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }
}
