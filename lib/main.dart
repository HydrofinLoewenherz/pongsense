import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:esense_flutter/esense.dart';
import 'package:permission_handler/permission_handler.dart';

import 'esense/sender.dart';
import 'flame/esense.dart';
import 'package:flame/game.dart';
import 'game/pong_game.dart';

typedef ESenseCallback = Future<void> Function();

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deviceName = 'Unknown';
  ConnectionType _connectionStatus = ConnectionType.unknown;
  bool sampling = false;
  List<int>? _accOffsets;
  ESenseConfig? _config;
  final Sender _sender = Sender(1000);
  StreamSubscription? eSenseEventSubscription;
  StreamSubscription? sensorEventSubscription;
  final PongGame _game = PongGame();

  // the name of the eSense device to connect to -- change this to your own device.
  // String eSenseName = 'eSense-0164';
  static const String eSenseDeviceName = 'eSense-0320';

  static const double gravity = 9.80665;
  static const double accelerometerScaleFactor = 8192;
  static const double gyroscopeScaleFactor = 65.5;

  ESenseManager eSenseManager = ESenseManager(eSenseDeviceName);

  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    // for some strange reason, Android requires permission to location for the eSense to work????
    if (Platform.isAndroid) await _askForPermissions();

    print("starting connection listeners");
    // TOOD: onError, onDone
    eSenseManager.connectionEvents.listen(_onConnectionEvent);

    print("connection to esense");
    await _connectToESense();
  }

  Future<bool> _askForPermission(Permission permission) async {
    final granted = (await permission.request().isGranted);
    if (!granted) {
      print('WARNING - no permission to use ${permission.toString()} granted.');
    }
    return granted;
  }

  Future<bool> _askForPermissions() async {
    return await _askForPermission(Permission.bluetooth) &&
        await _askForPermission(Permission.bluetoothScan) &&
        await _askForPermission(Permission.bluetoothConnect) &&
        await _askForPermission(Permission.locationWhenInUse);
  }

  void _onConnectionEvent(ConnectionEvent event) {
    print('CONNECTION event: $event');

    switch (event.type) {
      case ConnectionType.connected:
        _startListenToSensorEvents();
        break;
      case ConnectionType.disconnected:
        _stopListenToSensorEvents();
        break;
      case ConnectionType.unknown:
        // TODO: Handle this case.
        break;
      case ConnectionType.device_found:
        // TODO: Handle this case.
        break;
      case ConnectionType.device_not_found:
        // TODO: Handle this case.
        break;
    }

    setState(() {
      _connectionStatus = event.type;
    });
  }

  void _onESenseEvent(ESenseEvent event_) {
    print('ESENSE event: $event_');

    switch (_game.onESenseEvent(event_)) {
      case ESenseEventResult.handled:
        print('handled');
        return;
      case ESenseEventResult.ignored:
        print('ignored');
        break;
      case ESenseEventResult.skipRemainingHandlers:
        print('skipRemaining');
        return;
    }

    switch (event_.runtimeType) {
      case DeviceNameRead:
        final event = event_ as DeviceNameRead;
        _deviceName = event.deviceName!;
        break;
      case BatteryRead:
        final event = event_ as BatteryRead;
        break;
      case ButtonEventChanged:
        final event = event_ as ButtonEventChanged;
        break;
      case AccelerometerOffsetRead:
        final event = event_ as AccelerometerOffsetRead;
        _accOffsets = [event.offsetX!, event.offsetY!, event.offsetZ!];
        break;
      case AdvertisementAndConnectionIntervalRead:
        final event = event_ as AdvertisementAndConnectionIntervalRead;
        break;
      case SensorConfigRead:
        final event = event_ as SensorConfigRead;
        break;
    }
  }

  void _onSensorEvent(SensorEvent event) {
    switch (_game.onSensorEvent(event)) {
      case ESenseEventResult.handled:
        print('handled');
        return;
      case ESenseEventResult.ignored:
        print('ignored');
        break;
      case ESenseEventResult.skipRemainingHandlers:
        print('skipRemaining');
        return;
    }

    if (_config == null || _accOffsets == null) {
      print('SENSOR event: $event');
      print("Config or offsets not yet received");
      return;
    }

    var mappedAccOffsets =
        _accOffsets!.map((offset) => offset / AccRange.G_16.sensitivityFactor);
    var actualAccels = event.accel!.map((val) {
      return (val.toDouble() / _config!.accRange!.sensitivityFactor);
    });

    // ignore offsets
    // actualAccels is in g, almost in the range [-1, 1]

    print('offset: ${_accOffsets!}, acceel: ${actualAccels}');
  }

  Future<bool> _connectToESense() async {
    return _connectionStatus == ConnectionType.connected ||
        await eSenseManager.connect();
  }

  void _startListenToSensorEvents() async {
    // TOOD: onError, onDone
    eSenseEventSubscription = eSenseManager.eSenseEvents.listen(_onESenseEvent);
    sensorEventSubscription = eSenseManager.sensorEvents.listen(_onSensorEvent);

    // set listening config BEFORE listening
    print("setting listening config");
    _sender.pushAll([
      () => eSenseManager.setSamplingRate(10),
    ]);
    await Future.delayed(const Duration(milliseconds: 1000));

    // get basic data for internal state
    _sender.pushAll([
      eSenseManager.getDeviceName,
      eSenseManager.getAccelerometerOffset,
      eSenseManager.getAdvertisementAndConnectionInterval,
      eSenseManager.getSensorConfig,
      eSenseManager.getBatteryVoltage
    ]);

    setState(() {
      sampling = true;
    });
  }

  void _stopListenToSensorEvents() async {
    eSenseEventSubscription?.cancel();
    sensorEventSubscription?.cancel();
    setState(() {
      sampling = false;
    });
  }

  @override
  void dispose() {
    _stopListenToSensorEvents();
    eSenseManager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('eSense Demo App'),
        ),
        body: GameWidget(game: _game),
      ),
    );
  }
}
