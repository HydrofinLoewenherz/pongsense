import 'package:flutter/material.dart';
import 'package:pongsense/globals/connection.dart' as g;

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConnectScreenState createState() => ConnectScreenState();
}

class ConnectScreenState extends State<ConnectScreen> {
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
                Navigator.popAndPushNamed(context, '/game');
              },
              child: const Text('Game-Screen'),
            ),
            const Text('Connect-Screen'),
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
