import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pongsense/esense/sender.dart';

enum _State {
  waiting,
  searching,
  connecting,
  connected,
  initialized,
}

class Device {
  static const String deviceName = 'eSense-0320';
  static const Duration requestDelay = Duration(seconds: 1);
  static const Duration connectionDelay = Duration(milliseconds: 250);
  static const int samplingRate = 1;

  final _manager = ESenseManager(deviceName);
  final _sender = Sender(1000);

  StreamSubscription? _debugEventSub;
  StreamSubscription? _debugSensorSub;
  StreamSubscription? _debugConnectionSub;

  StreamSubscription? _connectionSub;

  String? _deviceName;
  ESenseConfig? _deviceConfig;
  ConnectionType? _connectionStatus;

  _State _state = _State.waiting;

  @override
  String toString() =>
      'State: ${_state.name}, Subbed: ${_connectionSub != null}, Connected: ${_manager.connected}';

  Future<bool> _askForPermission(Permission permission) async {
    return await permission.request().isGranted;
  }

  ESenseManager get manager => _manager;
  Sender get sender => _sender;

  Future<bool> _initialize() async {
    final queue = [
      () async => await _manager.setSamplingRate(samplingRate),
      () async => await _manager.getDeviceName(),
      () async => await _manager.getSensorConfig(),
    ];
    for (final req in queue) {
      if (!await req()) {
        return false;
      }
      await Future.delayed(requestDelay);
    }
    return true;
  }

  Future<void> _connect() async {
    if (!await _askForPermissions()) {
      throw Exception("permissions not given");
    }

    if (_connectionSub != null) {
      await _connectionSub!.cancel();
      _connectionSub = null;
    }

    _connectionSub = _manager.connectionEvents.listen((event) {
      switch (event.type) {
        case ConnectionType.unknown:
          assert(false, "encountered unknown state");
          break;
        case ConnectionType.connected:
          assert(_state == _State.connecting, "invalid state-sequence");
          _state = _State.connected;
          break;
        case ConnectionType.disconnected:
          assert(_state == _State.connected || _state == _State.initialized,
              "disconnected from invalid state");
          _state = _State.waiting;
          break;
        case ConnectionType.device_found:
          assert(_state == _State.searching, "invalid state-sequence");
          _state = _State.connecting;
          break;
        case ConnectionType.device_not_found:
          assert(_state == _State.searching, "invalid state-sequence");
          _state = _State.waiting;
          break;
      }
    });

    if (!await _manager.connect()) {
      throw Exception("couldn't start looking for device");
    }
    _state = _State.searching;

    for (;;) {
      await Future.delayed(connectionDelay);
      switch (_state) {
        case _State.waiting:
          if (!await _manager.connect()) {
            throw Exception("couldn't start looking for device");
          }
          _state = _State.searching;
          break; // look again
        case _State.searching:
          break; // keep waiting
        case _State.connecting:
          break; // keep waiting
        case _State.connected:
          return; // success
        case _State.initialized:
          throw Exception("initialized-state while connecting");
      }
    }
  }

  Future<bool> _disconnect() async {
    return await _manager.disconnect();
  }

  Future<bool> _askForPermissions() async {
    return await _askForPermission(Permission.bluetooth) &&
        await _askForPermission(Permission.bluetoothScan) &&
        await _askForPermission(Permission.bluetoothConnect) &&
        await _askForPermission(Permission.locationWhenInUse);
  }

  Future<bool> connectAndStartListening() async {
    if (_manager.connected) {
      throw Exception("already connected");
    }

    if (_state != _State.waiting) {
      throw Exception("already connecting");
    }

    if (_debugEventSub != null ||
        _debugSensorSub != null ||
        _debugConnectionSub != null) {
      await disconnectAndStopListening();
    }

    _debugConnectionSub = _manager.connectionEvents.listen((event) => print);
    await _connect();

    _debugEventSub = _manager.eSenseEvents.listen((event) => print);
    _debugSensorSub = _manager.sensorEvents.listen((event) => print);
    await _initialize();

    return true;
  }

  Future<bool> disconnectAndStopListening() async {
    if (_state != _State.initialized &&
        _state != _State.connected &&
        _state != _State.connecting) {
      throw Exception("not connected");
    }

    await _debugEventSub?.cancel();
    await _debugSensorSub?.cancel();
    await _debugConnectionSub?.cancel();
    await _connectionSub?.cancel();
    _debugEventSub = _debugSensorSub = _debugConnectionSub = null;
    _connectionSub = null;

    if (!await _disconnect()) {
      throw Exception("couldn't send disconnect request");
    }

    _state = _State.waiting;

    return true;
  }
}
