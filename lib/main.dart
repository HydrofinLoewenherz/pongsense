import 'package:flutter/material.dart';
import 'package:pongsense/routes/calibration.dart';
import 'package:pongsense/routes/connect.dart';
import 'package:pongsense/routes/game.dart';

void main() => runApp(const PongSense());

class PongSense extends StatelessWidget {
  const PongSense({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: Navigation(),
    );
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  NavigationState createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  int _currentTabIndex = 0;

  final gameScreen = const GameScreen();
  final calibrateScreen = const CalibrationScreen();
  final connectScreen = const ConnectScreen();

  @override
  void initState() {
    super.initState();
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.bluetooth_connected),
          label: "Connect",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate),
          label: "Calibrate",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gamepad),
          label: "Game",
        ),
      ],
      onTap: _onTap,
      currentIndex: _currentTabIndex,
    );
  }

  _onTap(int tabIndex) {
    if (_currentTabIndex == tabIndex) {
      return;
    }

    setState(() {
      _currentTabIndex = tabIndex;
    });
  }

  Widget get route {
    switch (_currentTabIndex) {
      case 0:
        return connectScreen;
      case 1:
        return calibrateScreen;
      case 2:
        return gameScreen;
      default:
        return connectScreen;
    }
  }

  String get routeTitle {
    switch (_currentTabIndex) {
      case 0:
        return "Connect";
      case 1:
        return "Calibrate";
      case 2:
        return "Game";
      default:
        return "Connect";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeTitle),
      ),
      body: route,
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }
}
