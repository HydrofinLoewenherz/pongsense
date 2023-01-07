import 'package:flame/components.dart';
import 'package:pongsense/game/pong_game.dart';

class PlayerScore extends PositionComponent with HasGameRef<PongGame> {
  late final TextComponent text;

  @override
  Future<void>? onLoad() {
    text = TextComponent(
      scale: Vector2(0.5, 0.5),
      text: "Score: ${gameRef.score}",
      position: Vector2(10.0, 10 + 10 + 10),
    );
    add(text);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    text.text = "Score: ${gameRef.score.floor()}";

    super.update(dt);
  }
}
