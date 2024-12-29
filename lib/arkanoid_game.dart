import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ArkanoidGame extends StatefulWidget {
  final String controlMethod;

  const ArkanoidGame({Key? key, required this.controlMethod}) : super(key: key);

  @override
  _ArkanoidGameState createState() => _ArkanoidGameState();
}

class _ArkanoidGameState extends State<ArkanoidGame> {
  late double paddleX;
  late double ballX, ballY;
  late double ballVelocityX, ballVelocityY;
  late Timer timer;
  late List<Offset> blocks;
  late int score;
  late int timeElapsed;
  final double paddleWidth = 100;
  final double paddleHeight = 20;
  final double ballSize = 15;
  final double blockWidth = 70;
  final double blockHeight = 30;
  final int numRows = 4;
  final int numCols = 5;

  late Timer speedIncreaseTimer;
  double sensitivity = 0.1; // Чувствительность гироскопа

  @override
  void initState() {
    super.initState();
    paddleX = 0.5;
    ballX = 0.5;
    ballY = 0.8;
    ballVelocityX = 0.01;
    ballVelocityY = -0.01;
    blocks = _initializeBlocks();
    score = 0;
    timeElapsed = 0;

    if (widget.controlMethod == 'Gyroscope') {
      gyroscopeEvents.listen((event) {
        setState(() {
          paddleX += event.y * sensitivity; // Увеличиваем чувствительность гироскопа
          paddleX = paddleX.clamp(0.0, 1.0);
        });
      });
    }

    timer = Timer.periodic(const Duration(milliseconds: 16), _updateGame);

    // Timer для увеличения скорости мяча каждые 5 секунд
    speedIncreaseTimer = Timer.periodic(const Duration(seconds: 5), _increaseSpeed);
  }

  List<Offset> _initializeBlocks() {
    List<Offset> blockList = [];
    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        blockList.add(Offset(col * blockWidth / 300.0 + 0.1, row * blockHeight / 600.0 + 0.1));
      }
    }
    return blockList;
  }

  void _increaseSpeed(Timer timer) {
    setState(() {
      ballVelocityX *= 1.1;
      ballVelocityY *= 1.1;
    });
  }

  void _updateGame(Timer timer) {
    setState(() {
      ballX += ballVelocityX;
      ballY += ballVelocityY;

      if (ballX <= 0 || ballX >= 1) ballVelocityX = -ballVelocityX;
      if (ballY <= 0) ballVelocityY = -ballVelocityY;

      if (ballY >= 1) {
        timer.cancel();
        _showGameOverDialog();
      }

      double paddleLeft = paddleX - paddleWidth / 600.0;
      double paddleRight = paddleX + paddleWidth / 600.0;
      double paddleTop = 0.9;

      if (ballY + ballSize / 600.0 >= paddleTop &&
          ballX >= paddleLeft &&
          ballX <= paddleRight) {
        ballVelocityY = -ballVelocityY;
      }

      blocks.removeWhere((block) {
        if (ballX >= block.dx &&
            ballX <= block.dx + blockWidth / 300.0 &&
            ballY >= block.dy &&
            ballY <= block.dy + blockHeight / 600.0) {
          ballVelocityY = -ballVelocityY;
          score += 1; // Увеличиваем счет
          return true;
        }
        return false;
      });

      timeElapsed += 1;
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: $score\nTry again?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                paddleX = 0.5;
                ballX = 0.5;
                ballY = 0.8;
                ballVelocityX = 0.01;
                ballVelocityY = -0.01;
                blocks = _initializeBlocks();
                score = 0;
                timeElapsed = 0;
                timer = Timer.periodic(const Duration(milliseconds: 16), _updateGame);
              });
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkanoid'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onPanUpdate: (details) {
              if (widget.controlMethod == 'Touch') {
                setState(() {
                  paddleX = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
                });
              }
            },
            child: Stack(
              children: [
                Positioned(
                  left: paddleX * constraints.maxWidth - paddleWidth / 2,
                  bottom: 20,
                  child: Container(
                    width: paddleWidth,
                    height: paddleHeight,
                    color: Colors.blue,
                  ),
                ),
                Positioned(
                  left: ballX * constraints.maxWidth - ballSize / 2,
                  top: ballY * constraints.maxHeight - ballSize / 2,
                  child: Container(
                    width: ballSize,
                    height: ballSize,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                ...blocks.map((block) => Positioned(
                      left: block.dx * constraints.maxWidth,
                      top: block.dy * constraints.maxHeight,
                      child: Container(
                        width: blockWidth,
                        height: blockHeight,
                        color: _getBlockColor(block),
                      ),
                    )),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Text(
                    'Score: $score',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 10,
                  child: Text(
                    'Time: ${timeElapsed ~/ 60}:${timeElapsed % 60}',
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getBlockColor(Offset block) {
    // Условный цвет блока
    if (block.dy < 0.2) {
      return Colors.green; // 1 балл
    } else if (block.dy < 0.4) {
      return Colors.blue; // 2 балла
    } else {
      return Colors.purple; // 3 балла
    }
  }

  @override
  void dispose() {
    timer.cancel();
    speedIncreaseTimer.cancel();
    super.dispose();
  }
}
