import 'package:esense_flutter/esense.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum ESenseEventResult {
  /// The event has been handled, and the event should not be propagated to
  /// other event handlers.
  handled,

  /// The event has not been handled, and the event should continue to be
  /// propagated to other event handlers, even non-Flutter ones.
  ignored,

  /// The event has not been handled, but the event should not be
  /// propagated to other event handlers.
  ///
  /// It will be returned to the platform embedding to be propagated to text
  /// fields and non-Flutter event handlers on the platform.
  skipRemainingHandlers,
}

/// A [Component] mixin to add esense handling capability to components.
/// Must be used in components that can only be added to games that are mixed
/// with [HasESenseHandlerComponents].
mixin ESenseHandler on Component {
  bool onESenseEvent(ESenseEvent event) {
    return true;
  }
}

mixin HasESenseHandlerComponents on FlameGame implements ESenseEvents {
  @override
  @mustCallSuper
  ESenseEventResult onESenseEvent(
    ESenseEvent event,
  ) {
    final blockedPropagation = !propagateToChildren<ESenseHandler>(
      (ESenseHandler child) => child.onESenseEvent(event),
    );

    // If any component received the event, return handled,
    // otherwise, ignore it.
    if (blockedPropagation) {
      return ESenseEventResult.handled;
    }
    return ESenseEventResult.ignored;
  }
}

/// A [Game] mixin to make a game subclass sensitive to esense events.
///
/// Override [onESenseEvent] to customize the esense handling behavior.
mixin ESenseEvents on Game {
  ESenseEventResult onESenseEvent(ESenseEvent event) {
    assert(
      this is! HasESenseHandlerComponents,
      'A esense event was registered by ESenseEvents for a game also '
      'mixed with HasESenseEventHandlerComponents. Do not mix with both, '
      'HasESenseEventHandlerComponents removes the necessity of ESenseEvents',
    );

    return ESenseEventResult.handled;
  }
}

/// The signature for a handle function
typedef ESenseHandlerCallback = bool Function(ESenseEvent event);

/// {@template keyboard_listener_component}
/// A [Component] that receives keyboard input and executes registered methods.
/// This component is based on [ESenseHandler], which requires the [FlameGame]
/// which is used to be mixed with [HasESenseHandlerComponents].
/// {@endtemplate}
class ESenseListenerComponent extends Component with ESenseHandler {
  /// {@macro keyboard_listener_component}
  ESenseListenerComponent({
    Map<Type, ESenseHandlerCallback> callbacks = const {},
  }) : _callbacks = callbacks;

  final Map<Type, ESenseHandlerCallback> _callbacks;

  @override
  bool onESenseEvent(ESenseEvent event) {
    final handler = _callbacks[event.runtimeType];

    if (handler != null) {
      return handler(event);
    }

    return true;
  }
}
