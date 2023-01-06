import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pongsense/esense/sender.dart';
import 'package:pongsense/util/pair.dart';

enum _State {
  waiting,
  searching,
  connecting,
  connected,
  initialized,
}

typedef Callback<T> = void Function(T);

class Device {
  static const String deviceName = 'eSense-0320';
  static const Duration requestDelay = Duration(seconds: 1);
  static const Duration connectionDelay = Duration(milliseconds: 250);
  static const int samplingRate = 1;

  final _manager = ESenseManager(deviceName);
  final _sender = Sender(1000);

  final _eventCallbacks = <Callback<ESenseEvent>>[];
  final _sensorCallbacks = <Callback<SensorEvent>>[];
  final _connectionCallbacks = <Callback<ConnectionEvent>>[];

  StreamSubscription? _debugEventSub;
  StreamSubscription? _debugSensorSub;
  StreamSubscription? _debugConnectionSub;

  StreamSubscription? _connectionSub;
  StreamSubscription? _eventSub;
  StreamSubscription? _sensorSub;

  StreamSubscription? _callbackConnectionSub;
  StreamSubscription? _callbackEventSub;
  StreamSubscription? _callbackSensorSub;

  String? _deviceName;
  double? _deviceBatteryVolt;
  ESenseConfig? _deviceConfig;

  _State _state = _State.waiting;

  @override
  String toString() {
    final getter = <Pair<String, String Function()>>[
      Pair('State', () => _state.name),
      Pair('Subbed', () => '${_connectionSub != null}'),
      Pair('Connected', () => '${_manager.connected}'),
      Pair('Name', () => '$_deviceName'),
      Pair('Config', () => '$_deviceConfig'),
      Pair('Voltage', () => '${_deviceBatteryVolt}V'),
    ];

    var buffer = '';
    for (var i = 0; i < getter.length; i += 1) {
      if (i > 0) buffer += '\n';
      buffer += '${getter[i].first}: ${getter[i].second()}';
    }
    return buffer;
  }

  void registerSensorCallback(Callback<SensorEvent> callback) {
    _sensorCallbacks.add(callback);
  }

  void registerEventCallback(Callback<ESenseEvent> callback) {
    _eventCallbacks.add(callback);
  }

  void registerConnectionCallback(Callback<ConnectionEvent> callback) {
    _connectionCallbacks.add(callback);
  }

  void clearSensorCallbacks() {
    _sensorCallbacks.clear();
  }

  void clearEventCallbacks() {
    _eventCallbacks.clear();
  }

  void clearConnectionCallbacks() {
    _connectionCallbacks.clear();
  }

  static void invokeCallbacks<T>(Iterable<Callback<T>> fns, T event) {
    for (final fn in fns) {
      fn(event);
    }
  }

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
      () async => await _manager.getBatteryVoltage(),
    ];
    for (final req in queue) {
      if (!await req()) {
        return false;
      }
      await Future.delayed(requestDelay);
    }

    for (;;) {
      if (_deviceName == null ||
          _deviceConfig == null ||
          _deviceBatteryVolt == null) {
        await Future.delayed(requestDelay);
        continue;
      }
      break;
    }

    return true;
  }

  Future<void> _connect() async {
    if (!await _askForPermissions()) {
      throw Exception("permissions not given");
    }

    _debugConnectionSub = _manager.connectionEvents.listen(print);
    _connectionSub = _manager.connectionEvents.listen(_onConnectionEvent);
    _callbackConnectionSub = _manager.connectionEvents.listen((event) {
      invokeCallbacks(_connectionCallbacks, event);
    });

    if (!await _manager.connect()) {
      throw Exception("couldn't start looking for device");
    }

    _state = _State.searching;

    for (;;) {
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
      await Future.delayed(connectionDelay);
    }
  }

  Future<bool> _disconnect() async {
    if (_state != _State.initialized &&
        _state != _State.connected &&
        _state != _State.connecting) {
      throw Exception("not connected");
    }

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

    await _connect();
    _debugEventSub = _manager.eSenseEvents.listen(print);
    _eventSub = _manager.eSenseEvents.listen(_onESenseEvent);
    _callbackEventSub = _manager.eSenseEvents.listen((event) {
      invokeCallbacks(_eventCallbacks, event);
    });

    await _initialize();
    _debugSensorSub = _manager.sensorEvents.listen(print);
    _sensorSub = _manager.sensorEvents.listen(_onSensorEvent);
    _callbackSensorSub = _manager.sensorEvents.listen((event) {
      invokeCallbacks(_sensorCallbacks, event);
    });

    return true;
  }

  void _onESenseEvent(ESenseEvent event_) {
    switch (event_.runtimeType) {
      case RegisterListenerEvent:
        final _ = event_ as RegisterListenerEvent;
        break;
      case DeviceNameRead:
        final e = event_ as DeviceNameRead;
        _deviceName = e.deviceName;
        break;
      case BatteryRead:
        final e = event_ as BatteryRead;
        _deviceBatteryVolt = e.voltage;
        break;
      case AccelerometerOffsetRead:
        final _ = event_ as AccelerometerOffsetRead;
        break;
      case AdvertisementAndConnectionIntervalRead:
        final _ = event_ as AdvertisementAndConnectionIntervalRead;
        break;
      case ButtonEventChanged:
        final _ = event_ as ButtonEventChanged;
        break;
      case SensorConfigRead:
        final e = event_ as SensorConfigRead;
        _deviceConfig = e.config;
        break;
    }
  }

  void _onSensorEvent(SensorEvent event) {}

  void _onConnectionEvent(ConnectionEvent event) {
    switch (event.type) {
      case ConnectionType.unknown:
        assert(true, "encountered unknown state");
        break;
      case ConnectionType.connected:
        // assert(_state == _State.connecting, "invalid state-sequence");
        _state = _State.connected;
        break;
      case ConnectionType.disconnected:
        // assert(_state == _State.connected || _state == _State.initialized,
        //     "disconnected from invalid state");
        _state = _State.waiting;
        break;
      case ConnectionType.device_found:
        // assert(_state == _State.searching, "invalid state-sequence");
        _state = _State.connecting;
        break;
      case ConnectionType.device_not_found:
        assert(_state == _State.searching, "invalid state-sequence");
        _state = _State.waiting;
        break;
    }
  }

  Future<void> _removeSubscriptions() async {
    await _debugEventSub?.cancel();
    await _debugSensorSub?.cancel();
    await _debugConnectionSub?.cancel();
    _debugEventSub = _debugSensorSub = _debugConnectionSub = null;

    await _eventSub?.cancel();
    await _sensorSub?.cancel();
    await _connectionSub?.cancel();
    _eventSub = _sensorSub = _connectionSub = null;

    await _callbackEventSub?.cancel();
    await _callbackSensorSub?.cancel();
    await _callbackConnectionSub?.cancel();
    _callbackEventSub = _callbackSensorSub = _callbackConnectionSub = null;
  }

  Future<bool> disconnectAndStopListening() async {
    _deviceBatteryVolt = _deviceConfig = _deviceName = null;

    if (_state != _State.initialized &&
        _state != _State.connected &&
        _state != _State.connecting) {
      _state = _State.waiting;
      return true;
    }

    await _removeSubscriptions();

    if (!await _disconnect()) {
      throw Exception("couldn't send disconnect request");
    }

    _state = _State.waiting;
    return true;
  }
}
