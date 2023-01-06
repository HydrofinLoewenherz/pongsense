import 'package:flutter/material.dart';
import 'package:pongsense/routes/connect.dart';
import 'package:pongsense/routes/game.dart';

void main() => runApp(const PongSense());

class PongSense extends StatefulWidget {
  const PongSense({super.key});

  @override
  PongSenseState createState() => PongSenseState();
}

class PongSenseState extends State<PongSense> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/connect',
      routes: {
        '/connect': (context) => const ConnectScreen(),
        '/game': (context) => const GameScreen(),
      },
    );
  }
}
