import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/presentation/screens/home/tabs/statistics_tab/views/saved_activity_view_options.dart';

sealed class ActivityDataPreparer {
  /// Groups given [activities] by one of [groupBy] options, then by
  /// [Sport]. A [displayMetric] must be provided in order to know what data to
  /// extract on each activity. All values with same date group and sport are
  /// summed together.
  ///
  /// Also ensures that there is no missing entry between two dates. For
  /// instance if grouping by month and the keys `DateTime(1999, 1)` and
  /// `DateTime(1999, 4)` are present, then so do `DateTime(1999, 2)` and
  /// `DateTime(1999, 3)`.
  ///
  /// Also returns the set of all encountered sports.
  static (SplayTreeMap<DateTime, Map<Sport, double>>, Set<Sport>) process(
    List<Activity> activities,
    ActivitiesGroupBy groupBy,
    ActivityDisplayMetric displayMetric,
  ) {
    final sumsByDateGroup = SplayTreeMap<DateTime, Map<Sport, double>>();
    // What sports are concerned by this activity set.
    final presentSports = <Sport>{};

    for (final activity in activities) {
      final dateGroup = DateTime(
        activity.startTime.year,
        groupBy != ActivitiesGroupBy.year ? activity.startTime.month : 1,
        groupBy == ActivitiesGroupBy.day ? activity.startTime.day : 1,
      );
      final sport = activity.sport ?? Sport.other;

      presentSports.add(sport);

      if (sumsByDateGroup.isEmpty) {
        sumsByDateGroup[dateGroup] = {};
      } else if (!sumsByDateGroup.containsKey(dateGroup)) {
        // Ensure all keys are present, there is no missing day/month/year.
        if (dateGroup.isBefore(sumsByDateGroup.firstKey()!)) {
          while (!sumsByDateGroup.containsKey(dateGroup)) {
            final nextKey = switch (groupBy) {
              ActivitiesGroupBy.day =>
                DateUtils.addDaysToDate(sumsByDateGroup.firstKey()!, -1),
              ActivitiesGroupBy.month => DateUtils.addMonthsToMonthDate(
                  sumsByDateGroup.firstKey()!,
                  -1,
                ),
              ActivitiesGroupBy.year =>
                DateTime(sumsByDateGroup.firstKey()!.year - 1),
            };
            sumsByDateGroup[nextKey] = {};
          }
        } else {
          while (!sumsByDateGroup.containsKey(dateGroup)) {
            final nextKey = switch (groupBy) {
              ActivitiesGroupBy.day =>
                DateUtils.addDaysToDate(sumsByDateGroup.lastKey()!, 1),
              ActivitiesGroupBy.month => DateUtils.addMonthsToMonthDate(
                  sumsByDateGroup.lastKey()!,
                  1,
                ),
              ActivitiesGroupBy.year =>
                DateTime(sumsByDateGroup.lastKey()!.year + 1),
            };
            sumsByDateGroup[nextKey] = {};
          }
        }
      }

      sumsByDateGroup[dateGroup]![sport] =
          (sumsByDateGroup[dateGroup]![sport] ?? 0) +
              switch (displayMetric) {
                ActivityDisplayMetric.distance =>
                  (activity.distanceInMeters ?? 0.0),
                ActivityDisplayMetric.duration =>
                  activity.duration.inMilliseconds.toDouble()
              };
    }

    // Add empty data just before that in order to be able to display anything
    if (sumsByDateGroup.length == 1) {
      final previous = switch (groupBy) {
        ActivitiesGroupBy.day =>
          DateUtils.addDaysToDate(sumsByDateGroup.firstKey()!, -1),
        ActivitiesGroupBy.month => DateUtils.addMonthsToMonthDate(
            sumsByDateGroup.firstKey()!,
            -1,
          ),
        ActivitiesGroupBy.year =>
          DateTime(sumsByDateGroup.firstKey()!.year - 1),
      };
      sumsByDateGroup[previous] = {};
    }

    return (sumsByDateGroup, presentSports);
  }
}
