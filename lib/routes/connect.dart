import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/esense/device.dart';
import 'package:pongsense/globals/connection.dart' as g;
import 'package:ditredi/ditredi.dart';
import 'package:pongsense/math/remap.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConnectScreenState createState() => ConnectScreenState();
}

class ConnectScreenState extends State<ConnectScreen> {
  static const int _maxLen = 60 * 1; // 60fps, 10s

  var _deviceInfo = g.device.toString();
  var _deviceState = g.device.state;
  var _lastAccels = ListQueue<Vector3>(_maxLen);
  var _lastGyros = ListQueue<Vector3>(_maxLen);
  final _controllerFront =
      DiTreDiController(rotationX: 0, rotationY: 0, rotationZ: 0);
  final _controllerTop =
      DiTreDiController(rotationX: 90, rotationY: 0, rotationZ: 0);

  Closer? _stateCallbackCloser;
  Closer? _eventCallbackCloser;
  Closer? _sensorCallbackCloser;

  List<Point3D> _generatePoints() {
    final len = _lastAccels.length;
    return _lastAccels.mapIndexed((v, i) {
      final alpha = (i / len).remap(0, 1, 0, 255).floor();
      return Point3D(v.normalized(),
          width: 2, color: Colors.red.withAlpha(alpha));
    }).toList();
  }

  List<Line3D> _generateLine() {
    final len = _lastAccels.length;
    if (len == 0) return [];
    final last = _lastAccels.last.normalized();
    return [
      Line3D(Vector3.zero(), last, width: 2, color: Colors.red.withAlpha(180)),
    ];
  }

  void _updateDevice() {
    setState(() {
      _deviceInfo = g.device.toString();
      _deviceState = g.device.state;
    });
  }

  static String _formatArray(Vector3? it) {
    if (it != null) {
      var buffer = '\n';
      buffer += '${it[0].toString()}\n';
      buffer += '${it[1].toString()}\n';
      buffer += it[2].toString();
      return buffer;
    }
    return 'null';
  }

  static Vector3? _toVec3(List<int>? it) {
    if (it == null || it.length < 3) return null;
    return Vector3(it[0].toDouble(), it[1].toDouble(), it[2].toDouble());
  }

  @override
  void initState() {
    super.initState();
    _stateCallbackCloser = g.device.registerStateCallback((state) {
      _updateDevice();
      if (state == DeviceState.waiting) {
        setState(() {
          _lastAccels = ListQueue<Vector3>(_maxLen);
          _lastGyros = ListQueue<Vector3>(_maxLen);
        });
      }
    });
    _eventCallbackCloser = g.device.registerEventCallback((_) {
      _updateDevice();
    });
    _sensorCallbackCloser = g.device.registerSensorCallback((event) {
      final gyro = _toVec3(event.gyro);
      final accel = _toVec3(event.accel);
      if (gyro == null || accel == null) return;
      setState(() {
        if (_lastGyros.length > _maxLen) _lastGyros.removeFirst();
        if (_lastAccels.length > _maxLen) _lastAccels.removeFirst();
        _lastGyros.addLast(gyro);
        _lastAccels.addLast(accel);
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
    final points = _generatePoints();
    final plane = PointPlane3D(2, Axis3D.y, 0.1, Vector3.zero(), pointWidth: 1);

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
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_deviceInfo),
            Text(
              'Gyro: ${_formatArray(_lastGyros.isEmpty ? null : _lastGyros.last)}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Accel: ${_formatArray(_lastAccels.isEmpty ? null : _lastAccels.last)}',
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
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 200,
                    color: Colors.blueGrey,
                    child: DiTreDiDraggable(
                      controller: _controllerFront,
                      child: DiTreDi(
                        bounds:
                            Aabb3.minMax(Vector3(-1, -1, -1), Vector3(1, 1, 1)),
                        config: const DiTreDiConfig(),
                        figures: [
                          plane,
                          ...points,
                          ..._generateLine(),
                        ],
                        controller: _controllerFront,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    color: Colors.blueGrey,
                    child: DiTreDiDraggable(
                      controller: _controllerTop,
                      child: DiTreDi(
                        bounds:
                            Aabb3.minMax(Vector3(-1, -1, -1), Vector3(1, 1, 1)),
                        config: const DiTreDiConfig(),
                        figures: [
                          plane,
                          ...points,
                          ..._generateLine(),
                        ],
                        controller: _controllerTop,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
