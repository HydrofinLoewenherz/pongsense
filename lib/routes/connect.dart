import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/esense/device.dart';
import 'package:pongsense/globals/connection.dart' as g;

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConnectScreenState createState() => ConnectScreenState();
}

class ConnectScreenState extends State<ConnectScreen> {
  String _deviceInfo = g.device.toString();
  DeviceState _deviceState = g.device.state;
  Closer? _stateCallbackCloser;
  Closer? _eventCallbackCloser;
  Closer? _sensorCallbackCloser;
  List<int>? _lastGyro;
  List<int>? _lastAccel;

  void _updateDevice() {
    setState(() {
      _deviceInfo = g.device.toString();
      _deviceState = g.device.state;
    });
  }

  static String _formatArray(List<int>? it) {
    if (it != null) {
      var buffer = '\n';
      for (final num in it) {
        if (buffer.length > 1) buffer += '\n';
        buffer += num.toString();
      }
      return buffer;
    }
    return 'null';
  }

  @override
  void initState() {
    super.initState();
    _stateCallbackCloser = g.device.registerStateCallback((state) {
      _updateDevice();
      if (state == DeviceState.waiting) {
        setState(() {
          _lastAccel = null;
          _lastGyro = null;
        });
      }
    });
    _eventCallbackCloser = g.device.registerEventCallback((_) {
      _updateDevice();
    });
    _sensorCallbackCloser = g.device.registerSensorCallback((event) {
      setState(() {
        _lastGyro = event.gyro;
        _lastAccel = event.accel;
      });
    });
  }

  @override
  void dispose() {
    _stateCallbackCloser?.call();
    _eventCallbackCloser?.call();
    _sensorCallbackCloser?.call();
    super.dispose();
  }

  VoidCallback? _onPressedConnect() {
    if (_deviceState != DeviceState.waiting) return null;
    return () {
      g.device.connectAndStartListening();
    };
  }

  VoidCallback? _onPressedDisconnect() {
    if (_deviceState != DeviceState.initialized) return null;
    return () {
      g.device.disconnectAndStopListening();
    };
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
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(_deviceInfo),
            Text(
              'Gyro: ${_formatArray(_lastGyro)}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Accel: ${_formatArray(_lastAccel)}',
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _onPressedConnect(),
                  child: const Text('Connect'),
                ),
                ElevatedButton(
                  onPressed: _onPressedDisconnect(),
                  child: const Text('Disconnect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
