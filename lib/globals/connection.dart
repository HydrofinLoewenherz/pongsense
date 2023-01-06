import 'package:pongsense/esense/device.dart';
import 'package:pongsense/game/pong_game.dart';

String connectionState = "";
Device device = Device();
PongGame game = PongGame(device.manager, device.sender);
