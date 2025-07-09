import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movna/domain/entities/sport.dart';

/// Convert a [Sport] instance to its Icon.
extension SportIconExt on Sport {
  IconData toIconData() => switch (this) {
        Sport.hiking => FontAwesomeIcons.personHiking,
        Sport.running => FontAwesomeIcons.personRunning,
        Sport.biking => FontAwesomeIcons.personBiking,
        Sport.other => FontAwesomeIcons.question,
      };
}
