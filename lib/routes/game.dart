import 'package:flutter/material.dart';
import 'package:pongsense/globals/connection.dart' as g;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, '/connect');
              },
              child: const Text('Connect-Screen'),
            ),
            const Text('Game-Screen'),
          ],
        ),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  g.connectionState += 'hi';
                });
              },
              child: Text('State: ${g.connectionState}')),
        ],
      ),
    );
  }
}
