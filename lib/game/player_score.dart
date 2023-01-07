import 'package:flame/components.dart';
import 'package:pongsense/game/pong_game.dart';

class PlayerScore extends PositionComponent with HasGameRef<PongGame> {
  late final TextComponent text;

  @override
  Future<void>? onLoad() {
    text = TextBoxComponent(
      text: "Score: ${gameRef.score}",
      position: Vector2(10.0, 10 + 10 + 5),
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
