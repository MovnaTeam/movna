import 'package:flutter/material.dart';
import 'package:movna/domain/entities/sport.dart';
import 'package:movna/presentation/extensions/sport_translation_extension.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/widgets/none_widget.dart';
import 'package:movna/presentation/screens/home/tabs/statistics_tab/widgets/legend_widget.dart';

/// Legend widget for the [SavedActivitiesChartContent] widget.
/// These two widget must be constructed from the same data.
class SavedActivitiesChartLegend extends StatelessWidget {
  const SavedActivitiesChartLegend({
    required this.sportColorMapping,
    super.key,
  });

  final Map<Sport, Color> sportColorMapping;

  @override
  Widget build(BuildContext context) {
    return sportColorMapping.length > 1
        ? LegendsListWidget(
            legends: sportColorMapping.entries
                .map(
                  (sportToColor) => Legend(
                    sportToColor.key.translatable().translate(context),
                    sportToColor.value,
                  ),
                )
                .toList(),
          )
        : const NoneWidget();
  }
}
