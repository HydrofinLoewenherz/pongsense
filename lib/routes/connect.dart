import 'package:flutter/material.dart';
import 'package:pongsense/esense/device.dart';
import 'package:pongsense/globals/connection.dart' as g;
import 'package:pongsense/util/callback.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConnectScreenState createState() => ConnectScreenState();
}

// TableRow(children: <TableCell>[
//                   TableCell(
//                     verticalAlignment: TableCellVerticalAlignment.middle,
//                     child: Text("Hello"),
//                   ),
//                   TableCell(
//                       verticalAlignment: TableCellVerticalAlignment.middle,
//                       child: Text("World"))
//                 ])

class YesNoRow extends TableRow {}

class ConnectScreenState extends State<ConnectScreen> {
  var _deviceState = g.device.state;

  var _receivedSensorEvent = false;
  var _receivedDeviceName = false;
  var _receivedBatteryVolt = false;
  var _receivedDeviceConfig = false;

  Closer? _stateCallbackCloser;
  Closer? _eventCallbackCloser;

  void _updateDevice() {
    setState(() {
      _receivedSensorEvent = g.device.receivedSensorEvent;
      _receivedDeviceName = g.device.receivedDeviceName;
      _receivedBatteryVolt = g.device.receivedBatteryVolt;
      _receivedDeviceConfig = g.device.receivedDeviceConfig;
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

  String get _buttonText {
    switch (_deviceState) {
      case DeviceState.waiting:
        return 'Connect';
      case DeviceState.searching:
      case DeviceState.connecting:
        return 'Connecting...';
      case DeviceState.connected:
      case DeviceState.initialized:
        return 'Disconnect';
    }
  }

  VoidCallback? _onPressed() {
    switch (_deviceState) {
      case DeviceState.waiting:
        return () {
          g.device.disconnectAndStopListening();
        };
      case DeviceState.searching:
      case DeviceState.connecting:
        return null;
      case DeviceState.connected:
      case DeviceState.initialized:
        return () {
          g.device.connectAndStartListening();
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: <Widget>[
                  const ListTile(
                    title: Text(
                      'Connection State',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading:
                        Icon(_receivedSensorEvent ? Icons.check : Icons.close),
                    title: const Text('Received Sensor-Event'),
                  ),
                  ListTile(
                    leading:
                        Icon(_receivedDeviceName ? Icons.check : Icons.close),
                    title: const Text('Received Device-Name'),
                  ),
                  ListTile(
                    leading:
                        Icon(_receivedBatteryVolt ? Icons.check : Icons.close),
                    title: const Text('Received Battery-Voltage'),
                  ),
                  ListTile(
                    leading:
                        Icon(_receivedDeviceConfig ? Icons.check : Icons.close),
                    title: const Text('Received Device-Config'),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: SizedBox(),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onPressed(),
                child: Text(_buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
