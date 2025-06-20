import 'package:json_locale/json_locale.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/jsons.dart';

/// Allows for translatable Sport instances.
extension SportTranslationExt on Sport {
  Translatable translatable() => switch (this) {
        Sport.hiking => LocaleKeys.enums.sport.hiking(),
        Sport.running => LocaleKeys.enums.sport.running(),
        Sport.biking => LocaleKeys.enums.sport.biking(),
        Sport.other => LocaleKeys.enums.sport.other(),
      };
}
