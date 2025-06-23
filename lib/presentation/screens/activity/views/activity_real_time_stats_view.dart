import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';

class ActivityRealTimeStatsView extends StatelessWidget {
  const ActivityRealTimeStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocSelector<LocationCubit, LocationCubitState, Location?>(
          selector: (state) => state.location?.location,
          builder: (BuildContext context, currentLocation) => Center(
            child: Text(
              '${currentLocation?.speedInMetersPerSecond.toStringAsFixed(1) ?? '-'} m/s',
            ),
          ),
        ),
      ],
    );
  }
}
