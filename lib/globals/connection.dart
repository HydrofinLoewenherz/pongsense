import 'package:pongsense/esense/angler.dart';
import 'package:pongsense/esense/device.dart';
import 'package:pongsense/game/pong_game.dart';

String connectionState = "";
Device device = Device();
Angler angler = Angler(device: device);
PongGame game = PongGame();
