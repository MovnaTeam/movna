import 'package:json_locale/json_locale.dart';
import 'package:movna/jsons.dart';

/// The property by which Activities can be sorted.
enum ActivitiesSortBy {
  startDate,
  duration,
  distance,
}

extension ActivitiesSortByTranslatableExt on ActivitiesSortBy {
  Translatable translatable() => switch (this) {
        ActivitiesSortBy.distance => LocaleKeys.activity.statistics.distance(),
        ActivitiesSortBy.startDate => LocaleKeys.activity.statistics.date(),
        ActivitiesSortBy.duration => LocaleKeys.activity.statistics.duration(),
      };
}

/// All time groups by which activities can be grouped by.
enum ActivitiesGroupBy {
  day,
  month,
  year,
}

extension ActivitiesGroupByTranslationExt on ActivitiesGroupBy {
  Translatable translatable() => switch (this) {
        ActivitiesGroupBy.day => LocaleKeys.units.day(),
        ActivitiesGroupBy.month => LocaleKeys.units.month(),
        ActivitiesGroupBy.year => LocaleKeys.units.year(),
      };
}

/// What can be displayed about an activity.
enum ActivityDisplayMetric {
  distance,
  duration,
}

extension ActivitiesDisplayMetricTranslationExt on ActivityDisplayMetric {
  Translatable translatable() => switch (this) {
        ActivityDisplayMetric.distance =>
          LocaleKeys.activity.statistics.distance(),
        ActivityDisplayMetric.duration =>
          LocaleKeys.activity.statistics.duration(),
      };
}
