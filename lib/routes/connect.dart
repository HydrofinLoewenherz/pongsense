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

const YesIcon = Icon(
  Icons.check,
  color: Colors.green,
);
const NoIcon = Icon(
  Icons.close,
  color: Colors.red,
);
const SyncIcon = Icon(
  Icons.sync,
  color: Colors.blue,
);

class ConnectScreenState extends State<ConnectScreen> {
  var _deviceState = g.device.state;

  var _receivedSensorEvent = g.device.receivedSensorEvent;
  var _receivedDeviceName = g.device.receivedDeviceName;
  var _receivedBatteryVolt = g.device.receivedBatteryVolt;
  var _receivedDeviceConfig = g.device.receivedDeviceConfig;

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
        return 'Searching...';
      case DeviceState.connecting:
        return 'Connecting...';
      case DeviceState.connected:
        return 'Initializing...';
      case DeviceState.initialized:
        return 'Disconnect';
    }
  }

  VoidCallback? _onPressed() {
    switch (_deviceState) {
      case DeviceState.waiting:
        return () {
          g.device.connectAndStartListening();
        };
      case DeviceState.searching:
      case DeviceState.connecting:
      case DeviceState.connected:
        return null;
      case DeviceState.initialized:
        return () {
          g.device.disconnectAndStopListening();
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
                    leading: _receivedSensorEvent
                        ? YesIcon
                        : (_deviceState == DeviceState.connected
                            ? SyncIcon
                            : NoIcon),
                    title: const Text('Received Sensor-Event'),
                  ),
                  ListTile(
                    leading: _receivedDeviceName
                        ? YesIcon
                        : (_deviceState == DeviceState.connected
                            ? SyncIcon
                            : NoIcon),
                    title: const Text('Received Device-Name'),
                  ),
                  ListTile(
                    leading: _receivedBatteryVolt
                        ? YesIcon
                        : (_deviceState == DeviceState.connected
                            ? SyncIcon
                            : NoIcon),
                    title: const Text('Received Battery-Voltage'),
                  ),
                  ListTile(
                    leading: _receivedDeviceConfig
                        ? YesIcon
                        : (_deviceState == DeviceState.connected
                            ? SyncIcon
                            : NoIcon),
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
