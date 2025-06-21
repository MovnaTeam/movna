import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';
import 'package:movna/presentation/screens/activity/views/map/constants.dart';
import 'package:movna/presentation/widgets/none_widget.dart';

/// Displays a location marker at the current device location or nothing if no
/// location is available.
///
/// See also:
///   * [Flutter map location marker package](https://pub.dev/packages/flutter_map_location_marker)
///   the plugin used to display and animate the marker from one location to the
///   next.
class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a bloc selector to rebuild only when the location changes
    return BlocSelector<LocationCubit, LocationCubitState, Location?>(
      selector: (state) {
        return state.location?.location;
      },
      builder: (context, location) {
        if (location == null) {
          return const NoneWidget();
        }
        return AnimatedLocationMarkerLayer(
          moveAnimationDuration: MapConstants.mapAnimationsDuration,
          moveAnimationCurve: MapConstants.mapAnimationsCurve,
          rotateAnimationDuration: MapConstants.mapAnimationsDuration,
          rotateAnimationCurve: MapConstants.mapAnimationsCurve,
          style: LocationMarkerStyle(
            accuracyCircleColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            headingSectorColor: Theme.of(context).colorScheme.primary,
            marker: DefaultLocationMarker(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          position: LocationMarkerPosition(
            latitude: location.gpsCoordinates.latitudeInDegrees,
            longitude: location.gpsCoordinates.longitudeInDegrees,
            accuracy: location.errorInMeters,
          ),
          heading: LocationMarkerHeading(
            heading: location.headingInDegrees * pi / 180,
            accuracy: 0.5,
          ),
        );
      },
    );
  }
}
