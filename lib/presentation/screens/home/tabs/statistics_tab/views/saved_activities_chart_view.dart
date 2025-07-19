import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/statistics_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/widgets/loading_indicator.dart';
import 'package:movna/presentation/screens/home/tabs/statistics_tab/views/helpers/activity_data_preparer.dart';
import 'package:movna/presentation/screens/home/tabs/statistics_tab/views/helpers/color_steps.dart';
import 'package:movna/presentation/screens/home/tabs/statistics_tab/views/saved_activities_chart_content.dart';
import 'package:movna/presentation/screens/home/tabs/statistics_tab/views/saved_activities_chart_legend.dart';
import 'package:movna/presentation/screens/home/tabs/statistics_tab/views/saved_activity_view_options.dart';

/// Widget that helps visualize saved activities provided by a [StatisticsCubit]
/// as a chart, with all chart options given to the user as well.
class SavedActivitiesChartView extends StatefulWidget {
  const SavedActivitiesChartView({super.key});

  @override
  State<SavedActivitiesChartView> createState() =>
      SavedActivitiesChartViewState();
}

class SavedActivitiesChartViewState extends State<SavedActivitiesChartView> {
  final _groupBy = ValueNotifier(ActivitiesGroupBy.month);
  final _displayOption = ValueNotifier(ActivityDisplayMetric.distance);
  final _cumulative = ValueNotifier(false);

  late final Listenable _chartConfig;

  @override
  void initState() {
    _chartConfig = Listenable.merge([_groupBy, _displayOption, _cumulative]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16.0,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.home.tabs.progress.savedActivitiesChart
                        .groupBy()
                        .translate(context),
                  ),
                  SizedBox(width: 8.0),
                  ValueListenableBuilder(
                    valueListenable: _groupBy,
                    builder: (context, groupBy, _) => DropdownButton(
                      value: groupBy,
                      onChanged: (ActivitiesGroupBy? value) {
                        if (value == null) return;
                        _groupBy.value = value;
                      },
                      items: ActivitiesGroupBy.values
                          .map<DropdownMenuItem<ActivitiesGroupBy>>((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                            value.translatable().translate(context),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.home.tabs.progress.savedActivitiesChart
                        .displayOption()
                        .translate(context),
                  ),
                  SizedBox(width: 8.0),
                  ValueListenableBuilder(
                    valueListenable: _displayOption,
                    builder: (context, displayOption, _) => DropdownButton(
                      value: displayOption,
                      onChanged: (ActivityDisplayMetric? value) {
                        if (value == null) return;
                        _displayOption.value = value;
                      },
                      items: ActivityDisplayMetric.values
                          .map<DropdownMenuItem<ActivityDisplayMetric>>(
                              (value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                            value.translatable().translate(context),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.home.tabs.progress.savedActivitiesChart
                        .cumulative()
                        .translate(context),
                  ),
                  SizedBox(width: 8.0),
                  ValueListenableBuilder(
                    valueListenable: _cumulative,
                    builder: (context, cumulative, _) => Checkbox(
                      value: cumulative,
                      onChanged: (value) {
                        if (value == null) return;
                        _cumulative.value = value;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          ListenableBuilder(
            listenable: _chartConfig,
            builder: (context, _) => Expanded(
              child: _SavedActivitiesChart(
                displayOption: _displayOption.value,
                groupBy: _groupBy.value,
                cumulative: _cumulative.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Intermediate widget that, given data prepared according to user
/// display config ([displayOption], [groupBy], [cumulative]), displays chart
/// legend and chart content using state from [StatisticsCubit].
class _SavedActivitiesChart extends StatelessWidget {
  const _SavedActivitiesChart({
    required this.displayOption,
    required this.groupBy,
    required this.cumulative,
  });

  final ActivityDisplayMetric displayOption;
  final ActivitiesGroupBy groupBy;

  /// True if the graphs are cumulated relative to time.
  final bool cumulative;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        return switch (state) {
          StatisticsStateInitial() ||
          StatisticsStateLoading() =>
            LoadingIndicator(),
          StatisticsStateError(/*:final fault*/) => Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
            ),
          StatisticsStateLoaded(:final activities) => Center(
              child: _buildStateLoaded(context, activities),
            ),
        };
      },
    );
  }

  Widget _buildStateLoaded(
    BuildContext context,
    List<Activity> activities,
  ) {
    final (sumsByDateGroup, presentSports) =
        ActivityDataPreparer.process(activities, groupBy, displayOption);

    final sportColorMapping = Map.fromIterables(
      presentSports,
      ColorSteps.create(
        Theme.of(context).colorScheme.primary,
        presentSports.length,
      ),
    );

    if (activities.isEmpty) {
      return Center(
        child: Text(LocaleKeys.home.tabs.progress.noData().translate(context)),
      );
    }

    return Column(
      children: [
        SavedActivitiesChartLegend(sportColorMapping: sportColorMapping),
        Expanded(
          child: SavedActivitiesChartContent(
            sportColorMapping: sportColorMapping,
            preparedData: sumsByDateGroup,
            cumulative: cumulative,
            displayOption: displayOption,
            groupBy: groupBy,
          ),
        ),
      ],
    );
  }
}
