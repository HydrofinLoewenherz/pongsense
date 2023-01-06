import 'package:flutter/material.dart';
import 'package:pongsense/globals/connection.dart' as g;

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConnectScreenState createState() => ConnectScreenState();
}

class ConnectScreenState extends State<ConnectScreen> {
  String _state = g.device.toString();

  @override
  void initState() {
    super.initState();
    g.device.registerConnectionCallback((_) {
      setState(() {
        _state = g.device.toString();
      });
    });
    g.device.registerEventCallback((_) {
      setState(() {
        _state = g.device.toString();
      });
    });
  }

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
          Text(_state),
          ElevatedButton(
              onPressed: () {
                g.device.connectAndStartListening();
              },
              child: const Text('Connect')),
          ElevatedButton(
              onPressed: () {
                g.device.disconnectAndStopListening();
              },
              child: const Text('Disconnect')),
        ],
      ),
    );
  }
}
