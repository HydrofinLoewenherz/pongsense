import 'dart:collection';
import 'dart:math';

import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pongsense/esense/device.dart';
import 'package:pongsense/globals/connection.dart' as g;
import 'package:ditredi/ditredi.dart';
import 'package:pongsense/math/remap.dart';
import 'package:pongsense/math/vector.dart';
import 'package:pongsense/util/callback.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  CalibrationScreenState createState() => CalibrationScreenState();
}

class CalibrationScreenState extends State<CalibrationScreen> {
  static const int _maxLen = 60 * 1; // 60fps, 10s
  static final _calibrationColorLeft = Colors.pink.withAlpha(180);
  static final _calibrationColorRight = Colors.green.withAlpha(180);
  static final _bounds = Aabb3.minMax(Vector3(-1, -1, -1), Vector3(1, 1, 1));

  var _lastAccels = ListQueue<Vector3>(_maxLen);
  var _lastGyros = ListQueue<Vector3>(_maxLen);
  var _deviceState = g.device.state;

  Vector3? _calibrateLeft;
  Vector3? _calibrateRight;
  double? _lastAngleLeft;
  double? _lastAngleRight;

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
  Closer? _angleChangedCallbackCloser;

  List<Point3D> _generateAccelPoints() {
    final len = _lastAccels.length;
    return _lastAccels.mapIndexed((v, i) {
      final alpha = (i / len).remap(0, 1, 0, 255).floor();
      return Point3D(v.normalized(),
          width: 2, color: Colors.red.withAlpha(alpha));
    }).toList();
  }

  List<Line3D> _generateAccelLine() {
    final len = _lastAccels.length;
    if (len == 0) return [];
    final last = _lastAccels.last.normalized();
    return [
      Line3D(
        Vector3.zero(),
        last,
        width: 2,
        color: Colors.red.withAlpha(180),
      )
    ];
  }

  List<Line3D> _generateCalibrationLines() {
    var buffer = <Line3D>[];
    final left = _calibrateLeft;
    final right = _calibrateRight;

    if (left != null) {
      buffer.add(Line3D(
        Vector3.zero(),
        left.normalized(),
        width: 2,
        color: _calibrationColorLeft,
      ));
    }
    if (right != null) {
      buffer.add(Line3D(
        Vector3.zero(),
        right.normalized(),
        width: 2,
        color: _calibrationColorRight,
      ));
    }

    return buffer;
  }

  VoidCallback? _onPressCalibrateLeft() {
    return () {
      if (g.angler.doCalibrateLeft()) {
        setState(() {
          _calibrateLeft = g.angler.calibrateLeft;
        });
      }
    };
  }

  VoidCallback? _onPressCalibrateRight() {
    return () {
      if (g.angler.doCalibrateRight()) {
        setState(() {
          _calibrateRight = g.angler.calibrateRight;
        });
      }
    };
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
      final gyro = toVec3(event.gyro);
      final accel = toVec3(event.accel);
      if (gyro == null || accel == null) return;
      setState(() {
        if (_lastGyros.length > _maxLen) _lastGyros.removeFirst();
        if (_lastAccels.length > _maxLen) _lastAccels.removeFirst();
        _lastGyros.addLast(gyro);
        _lastAccels.addLast(accel);
      });
    });
    _angleChangedCallbackCloser =
        g.angler.registerAngleChangedCallback((event) {
      setState(() {
        _lastAngleLeft = event.leftAngle;
        _lastAngleRight = event.rightAngle;
      });
    });
  }

  @override
  void dispose() {
    _sensorCallbackCloser?.call();
    _stateCallbackCloser?.call();
    _angleChangedCallbackCloser?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = _generateAccelPoints();
    final plane = PointPlane3D(2, Axis3D.y, 0.1, Vector3.zero(), pointWidth: 1);
    final figures = <Model3D>[
      plane,
      ...points,
      ..._generateAccelLine(),
      ..._generateCalibrationLines(),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(children: [
                  ElevatedButton(
                    onPressed: _onPressCalibrateLeft(),
                    child: const Text('Calibrate Left'),
                  ),
                  ElevatedButton(
                    onPressed: _onPressCalibrateRight(),
                    child: const Text('Calibrate Right'),
                  )
                ]),
                Text('AngleLeft: ${_lastAngleLeft?.radToDeg().floor()}'),
                Text('AngleRight: ${_lastAngleRight?.radToDeg().floor()}'),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  color: Colors.blueGrey,
                  child: DiTreDiDraggable(
                    controller: _controllerFront,
                    child: DiTreDi(
                      bounds: _bounds,
                      config: const DiTreDiConfig(),
                      figures: figures,
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
                      bounds: _bounds,
                      config: const DiTreDiConfig(),
                      figures: figures,
                      controller: _controllerTop,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
