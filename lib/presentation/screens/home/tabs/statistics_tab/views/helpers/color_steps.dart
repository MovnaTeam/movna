import 'package:flutter/widgets.dart';

sealed class ColorSteps {
  /// Crate list of [count] colors that go from white to [target].
  static List<Color> create(Color target, int count) {
    final primary = HSVColor.fromColor(target);
    return List.generate(
      count,
      (i) => primary
          .withValue(
            (primary.value * (i + 1) / count) + (1 - ((i + 1) / count)),
          )
          .withSaturation(primary.saturation * (i + 1) / count)
          .toColor(),
    );
  }
}
