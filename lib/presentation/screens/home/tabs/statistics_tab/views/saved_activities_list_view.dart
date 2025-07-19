import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/statistics_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/widgets/loading_indicator.dart';
import 'package:movna/presentation/screens/home/tabs/statistics_tab/views/saved_activity_view_options.dart';
import 'package:movna/presentation/screens/home/tabs/statistics_tab/widgets/saved_activity_card.dart';

/// Display of the activities provided by a parent [StatisticsCubit].
class SavedActivitiesListView extends StatefulWidget {
  const SavedActivitiesListView({super.key});

  @override
  State<SavedActivitiesListView> createState() =>
      _SavedActivitiesListViewState();
}

class _SavedActivitiesListViewState extends State<SavedActivitiesListView> {
  final _sortProperty =
      ValueNotifier<ActivitiesSortBy>(ActivitiesSortBy.startDate);
  final _sortOrderAscending = ValueNotifier<bool>(false);

  late final Listenable _sort;

  @override
  void initState() {
    _sort = Listenable.merge([_sortProperty, _sortOrderAscending]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              LocaleKeys.home.savedActivitiesListSortBy().translate(context),
            ),
            SizedBox(
              width: 16.0,
            ),
            ValueListenableBuilder(
              valueListenable: _sortProperty,
              builder: (context, sortBy, _) => DropdownButton(
                value: sortBy,
                onChanged: (ActivitiesSortBy? value) {
                  if (value == null) return;
                  _sortProperty.value = value;
                },
                items: ActivitiesSortBy.values
                    .map<DropdownMenuItem<ActivitiesSortBy>>(
                        (ActivitiesSortBy value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value.translatable().translate(context),
                    ),
                  );
                }).toList(),
              ),
            ),
            IconButton(
              onPressed: () =>
                  _sortOrderAscending.value = !_sortOrderAscending.value,
              icon: ValueListenableBuilder(
                valueListenable: _sortOrderAscending,
                builder: (context, value, _) =>
                    Icon(value ? Icons.arrow_upward : Icons.arrow_downward),
              ),
            ),
          ],
        ),
        BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: _buildSortedListView,
        ),
      ],
    );
  }

  Widget _buildSortedListView(BuildContext context, StatisticsState state) {
    return Expanded(
      child: switch (state) {
        StatisticsStateInitial() ||
        StatisticsStateLoading() =>
          LoadingIndicator(),
        StatisticsStateError(/*:final fault*/) => Icon(
            Icons.warning,
            color: Theme.of(context).colorScheme.error,
          ),
        StatisticsStateLoaded(:final activities) => Center(
            child: ListenableBuilder(
              listenable: _sort,
              builder: (context, _) {
                final sortedActivities = List.from(activities, growable: false)
                  ..sort((a, b) {
                    return (switch (_sortProperty.value) {
                          ActivitiesSortBy.startDate =>
                            a.startTime.millisecondsSinceEpoch <
                                b.startTime.millisecondsSinceEpoch,
                          ActivitiesSortBy.duration => a.duration < b.duration,
                          ActivitiesSortBy.distance =>
                            (a.distanceInMeters ?? 0) <
                                (b.distanceInMeters ?? 0),
                        }
                            ? -1
                            : 1) *
                        (_sortOrderAscending.value ? 1 : -1);
                  });
                return ListView.builder(
                  itemCount: sortedActivities.length,
                  itemBuilder: (context, i) =>
                      SavedActivityCard(activity: sortedActivities[i]),
                );
              },
            ),
          ),
      },
    );
  }
}
