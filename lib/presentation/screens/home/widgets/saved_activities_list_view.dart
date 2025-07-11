import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/presentation/blocs/statistics_cubit.dart';
import 'package:movna/presentation/screens/common/widgets/loading_indicator.dart';
import 'package:movna/presentation/screens/home/widgets/saved_activity_card.dart';

/// Display of the activities provided by a parent [StatisticsCubit].
class SavedActivitiesListView extends StatelessWidget {
  const SavedActivitiesListView({super.key});

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
              child: ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, i) =>
                    SavedActivityCard(activity: activities[i]),
              ),
            ),
        };
      },
    );
  }
}
