import 'package:flutter/material.dart';
import 'package:movna/domain/entities/sport.dart';

/// Convert a [Sport] instance to a unique [Color] based on context primary one.
extension SportColorExt on Sport? {
  Color toColor(BuildContext context) {
    final primary = HSVColor.fromColor(Theme.of(context).colorScheme.primary);

    if (this == null || this == Sport.other) {
      return primary.withSaturation(0).toColor();
    }

    final index =
        this!.index < Sport.other.index ? this!.index : this!.index - 1;
    final colorCount = Sport.values.length - 1;
    final hueOffset = 360.0 / colorCount;

    return primary
        .withHue(
            (primary.hue + /*(hueOffset / 2) +*/ hueOffset * index) % 360.0)
        .toColor();
  }
}
