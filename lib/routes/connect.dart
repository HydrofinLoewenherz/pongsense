import 'package:flutter/material.dart';
import 'package:pongsense/esense/device.dart';
import 'package:pongsense/globals/connection.dart' as g;
import 'package:pongsense/util/callback.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConnectScreenState createState() => ConnectScreenState();
}

class ConnectScreenState extends State<ConnectScreen> {
  var _deviceInfo = g.device.toString();
  var _deviceState = g.device.state;

  Closer? _stateCallbackCloser;
  Closer? _eventCallbackCloser;

  void _updateDevice() {
    setState(() {
      _deviceInfo = g.device.toString();
      _deviceState = g.device.state;
    });
  }

  @override
  void initState() {
    super.initState();
    _stateCallbackCloser = g.device.registerStateCallback((state) {
      _updateDevice();
    });
    _eventCallbackCloser = g.device.registerEventCallback((_) {
      _updateDevice();
    });
  }

  @override
  void dispose() {
    _stateCallbackCloser?.call();
    _eventCallbackCloser?.call();
    super.dispose();
  }

  VoidCallback? _onPressedConnect() {
    if (_deviceState != DeviceState.waiting) return null;
    return () {
      g.device.connectAndStartListening();
    };
  }

  VoidCallback? _onPressedDisconnect() {
    if (_deviceState != DeviceState.initialized &&
        _deviceState != DeviceState.connected) return null;
    return () {
      g.device.disconnectAndStopListening();
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_deviceInfo),
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
