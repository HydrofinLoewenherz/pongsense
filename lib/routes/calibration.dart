import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/components/nav_bar.dart';
import 'package:pongsense/components/nav_button.dart';
import 'package:pongsense/esense/device.dart';
import 'package:pongsense/globals/connection.dart' as g;
import 'package:ditredi/ditredi.dart';
import 'package:pongsense/math/remap.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  CalibrationScreenState createState() => CalibrationScreenState();
}

class CalibrationScreenState extends State<CalibrationScreen> {
  static const int _maxLen = 60 * 1; // 60fps, 10s
  static final _bounds = Aabb3.minMax(Vector3(-1, -1, -1), Vector3(1, 1, 1));

  var _lastAccels = ListQueue<Vector3>(_maxLen);
  var _lastGyros = ListQueue<Vector3>(_maxLen);
  var _deviceState = g.device.state;

  var _calibrationAccels = <Vector3>[];

  final _controllerFront = DiTreDiController(
    rotationX: 0,
    rotationY: 0,
    rotationZ: 0,
  );
  final _controllerTop = DiTreDiController(
    rotationX: 90,
    rotationY: 0,
    rotationZ: 0,
  );

  Closer? _sensorCallbackCloser;
  Closer? _stateCallbackCloser;

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

  static Vector3? _toVec3(List<int>? it) {
    if (it == null || it.length < 3) return null;
    return Vector3(it[0].toDouble(), it[1].toDouble(), it[2].toDouble());
  }

  @override
  void initState() {
    super.initState();
    _stateCallbackCloser = g.device.registerStateCallback((state) {
      if (state == _deviceState) return;
      setState(() {
        _deviceState = state;
        if (state == DeviceState.waiting) {
          _lastAccels = ListQueue<Vector3>(_maxLen);
          _lastGyros = ListQueue<Vector3>(_maxLen);
        }
      });
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
    _sensorCallbackCloser?.call();
    _stateCallbackCloser?.call();
    super.dispose();
  }

  VoidCallback? _onPressedToGame() {
    if (_deviceState != DeviceState.initialized) return null;
    return () {
      Navigator.popAndPushNamed(context, '/game');
    };
  }

  VoidCallback? _onPressedToConnect() {
    return () {
      Navigator.popAndPushNamed(context, '/connect');
    };
  }

  @override
  Widget build(BuildContext context) {
    final points = _generatePoints();
    final plane = PointPlane3D(2, Axis3D.y, 0.1, Vector3.zero(), pointWidth: 1);

    return Scaffold(
      appBar: NavBar(
        title: 'Calibrate',
        leftButton: NavButton(
          onPressed: _onPressedToConnect(),
          child: const Text('Connect'),
        ),
        rightButton: NavButton(
          onPressed: _onPressedToGame(),
          child: const Text('Play'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 300,
                  color: Colors.blueGrey,
                  child: DiTreDiDraggable(
                    controller: _controllerFront,
                    child: DiTreDi(
                      bounds: _bounds,
                      config: const DiTreDiConfig(),
                      figures: [plane, ...points, ..._generateLine()],
                      controller: _controllerFront,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  color: Colors.blueGrey,
                  child: DiTreDiDraggable(
                    controller: _controllerTop,
                    child: DiTreDi(
                      bounds: _bounds,
                      config: const DiTreDiConfig(),
                      figures: [plane, ...points, ..._generateLine()],
                      controller: _controllerTop,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
