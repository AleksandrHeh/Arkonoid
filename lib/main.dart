// main.dart

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'arkanoid_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arkanoid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameSettings(),
    );
  }
}

class GameSettings extends StatefulWidget {
  const GameSettings({Key? key}) : super(key: key);

  @override
  State<GameSettings> createState() => _GameSettingsState();
}

class _GameSettingsState extends State<GameSettings> {
  String controlMethod = 'Gyroscope';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkanoid Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Select Control Method:',
            style: TextStyle(fontSize: 20),
          ),
          ListTile(
            title: const Text('Gyroscope'),
            leading: Radio<String>(
              value: 'Gyroscope',
              groupValue: controlMethod,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    controlMethod = value;
                  });
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Touch'),
            leading: Radio<String>(
              value: 'Touch',
              groupValue: controlMethod,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    controlMethod = value;
                  });
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArkanoidGame(controlMethod: controlMethod),
                ),
              );
            },
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }
}
