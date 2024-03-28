import 'dart:math';
import 'package:roulette/roulette.dart';
import 'package:flutter/material.dart';

import 'controls/arrow.dart';

class MyRoulette extends StatelessWidget {
  const MyRoulette({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final RouletteController controller;

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

  final colors = <Color>[
    Colors.red.withAlpha(50),
    Colors.green.withAlpha(30),
    Colors.blue.withAlpha(70),
    Colors.yellow.withAlpha(90),
    Colors.amber.withAlpha(50),
    Colors.indigo.withAlpha(70),
  ];

  final icons = <IconData>[
    Icons.ac_unit,
    Icons.access_alarm,
    Icons.access_time,
    Icons.accessibility,
    Icons.account_balance,
    Icons.account_balance_wallet,
  ];

  var texts = <String>[
    "이화수 1호점",
    "이화수 2호점",
    "이화수 3호점",
    "이화수 4호점",
    "이화수 5호점",
    "이화수 6호점",
  ];

  @override
  void initState() {
    // Initialize the controller
    final group = RouletteGroup.uniform(
      colors.length,
      textBuilder: texts.elementAt,
      colorBuilder: colors.elementAt,
      textStyleBuilder: (index) => const TextStyle(
        color: Colors.black,
      ),
    );

    _controller = RouletteController(vsync: this, group: group);

    _controller.animation.addStatusListener((status) {
          if (status.name == "completed")
            {
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
