import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/extensions/sport_icon_extension.dart';
import 'package:movna/presentation/extensions/sport_translation_extension.dart';
import 'package:movna/presentation/locale/locales_helper.dart';

/// Widget that represents essential information on a [Activity], to be
/// displayed in a list.
class SavedActivityCard extends StatelessWidget {
  const SavedActivityCard({required this.activity, super.key});
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final cardTitle = activity.name != null && activity.name!.isNotEmpty
        ? activity.name!
        : (activity.sport ?? Sport.other).translatable().translate(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 12),
                child: Icon(
                  activity.sport?.toIconData() ?? Icons.question_mark,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      style: DefaultTextStyle.of(context).style.apply(
                            fontSizeFactor: 1.2,
                            fontWeightDelta: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      cardTitle,
                    ),
                  ),
                  _buildStatsRow(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final durationFormat = NumberFormat('00');
    final durationString =
        '${durationFormat.format(activity.duration.inHours)}:'
        '${durationFormat.format(
      activity.duration.inMinutes.remainder(
        Duration.minutesPerHour,
      ),
    )}:'
        '${durationFormat.format(
      activity.duration.inSeconds.remainder(
        Duration.secondsPerMinute,
      ),
    )}';
    final distanceString = activity.distanceInMeters == null
        ? '0 ${LocaleKeys.units.metersShort().translate(
              context,
            )}'
        : (activity.distanceInMeters! < 1_000
            ? '${activity.distanceInMeters!.toStringAsFixed(0)} '
                '${LocaleKeys.units.metersShort().translate(context)}'
            : '${(activity.distanceInMeters! / 1_000).toStringAsFixed(1)} '
                '${LocaleKeys.units.kilometersShort().translate(context)}');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(DateFormat.yMd().format(activity.startTime))),
        Expanded(child: Text(textAlign: TextAlign.center, durationString)),
        Expanded(child: Text(textAlign: TextAlign.right, distanceString)),
      ],
    );
  }
}
