import 'dart:io';

import 'package:intl/intl.dart';
import 'package:movna/presentation/screens/home/tabs/statistics_tab/views/saved_activity_view_options.dart';

/// Converts dates back and forth to double values.
/// The values are guaranteed to be incremental with a step of exactly 1.0.
/// Meaning that depending on [step] :
/// - [ActivitiesGroupBy.day] a step of 1.0 is one day.
/// - [ActivitiesGroupBy.month] a step of 1.0 is one month.
/// - [ActivitiesGroupBy.year] a step of 1.0 is one year.
/// BUT this converter will not use the same date as 0 for all types of
/// [ActivitiesGroupBy] options.
///
/// In all cases, only year, month and day *can* be used,
/// time of day is discarded.
class DoubleToDateConverter {
  const DoubleToDateConverter(this.step);

  static const _millisecondsPerDay = 1_000 * 60 * 60 * 24;

  final ActivitiesGroupBy step;

  double from(DateTime dateTime) => switch (step) {
        ActivitiesGroupBy.day =>
          dateTime.millisecondsSinceEpoch / _millisecondsPerDay,
        ActivitiesGroupBy.month =>
          (dateTime.year * DateTime.monthsPerYear + dateTime.month - 1)
              .toDouble(),
        ActivitiesGroupBy.year => dateTime.year.toDouble()
      };

  DateTime to(double x) => switch (step) {
        ActivitiesGroupBy.day =>
          DateTime.fromMillisecondsSinceEpoch(x.toInt() * _millisecondsPerDay),
        ActivitiesGroupBy.month => DateTime(
            (x / DateTime.monthsPerYear).toInt(),
            x.remainder(DateTime.monthsPerYear).toInt() + 1,
          ),
        ActivitiesGroupBy.year => DateTime(x.toInt()),
      };
}

/// Converts given [dateTime] to displayable text according to the type of
/// dateTime groups [groupBy] used by the chart.
String dateTimeToText(DateTime dateTime, ActivitiesGroupBy groupBy) {
  return switch (groupBy) {
    ActivitiesGroupBy.day => DateFormat.yMMMd,
    ActivitiesGroupBy.month => DateFormat.yMMM,
    ActivitiesGroupBy.year => DateFormat.y,
  }(Platform.localeName)
      .format(dateTime);
}
