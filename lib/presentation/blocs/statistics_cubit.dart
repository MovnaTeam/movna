import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/activity.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/usecases/get_activities.dart';
import 'package:result_dart/result_dart.dart';

part 'statistics_cubit.freezed.dart';

/// A cubit that is able to fetch past activities in order for the UI to display
/// as many information as necessary.
@injectable
class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(this._getActivities)
      : super(const StatisticsState.initial()) {
    emit(StatisticsState.loading());
    _getActivitiesFuture = _getActivities()..then(_onActivitiesRetrieved);
  }

  // TODO make this use-case take an "ActivityFilter" object in order to get
  // only some activities.
  final GetActivities _getActivities;
  Future<ResultDart<List<Activity>, Fault>>? _getActivitiesFuture;

  FutureOr _onActivitiesRetrieved(ResultDart<List<Activity>, Fault> value) {
    value.fold(
      (list) => emit(StatisticsState.loaded(activities: list)),
      (fault) => emit(StatisticsState.error(fault: fault)),
    );
  }

  @override
  Future<void> close() {
    _getActivitiesFuture?.ignore();
    return super.close();
  }
}

@freezed
sealed class StatisticsState with _$StatisticsState {
  const StatisticsState._();

  const factory StatisticsState.initial() = StatisticsStateInitial;
  const factory StatisticsState.loading() = StatisticsStateLoading;

  const factory StatisticsState.loaded({
    @Default([]) List<Activity> activities,
  }) = StatisticsStateLoaded;

  const factory StatisticsState.error({required Fault fault}) =
      StatisticsStateError;
}
