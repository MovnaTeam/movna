import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';
import 'package:movna/domain/entities/track_segment.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/extensions/gps_coordinates_extensions.dart';
import 'package:movna/presentation/widgets/none_widget.dart';

class ActivityMapLayer extends StatelessWidget {
  const ActivityMapLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // TrackPoints layer
        BlocSelector<ActivityCubit, ActivityState, List<TrackSegment>?>(
          selector: (state) => state.activity?.trackSegments,
          builder: (context, trackSegments) {
            if (trackSegments == null) return NoneWidget();
            // Polyline errors if less than 2 points.
            final segmentsWithMoreThanTwoPoints = trackSegments.where(
              (ts) =>
                  ts.trackPoints.where((tp) => tp.location != null).length >= 2,
            );
            return PolylineLayer(
              polylines: segmentsWithMoreThanTwoPoints
                  .map(
                    (ts) => Polyline(
                      points: ts.trackPoints
                          .where((tp) => tp.location != null)
                          .map(
                            (tp) => tp.location!.gpsCoordinates.toLatLng(),
                          )
                          .toList(),
                      color: Theme.of(context).colorScheme.primary,
                      borderColor: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 5.0,
                      borderStrokeWidth: 5.0,
                    ),
                  )
                  .toList(),
            );
          },
        ),
        // Start Point Layer
        BlocSelector<ActivityCubit, ActivityState, GpsCoordinates?>(
          selector: (state) => state.activity?.trackSegments.firstOrNull
              ?.trackPoints.firstOrNull?.location?.gpsCoordinates,
          builder: (context, startPoint) {
            if (startPoint == null) return NoneWidget();
            return CircleLayer(
              circles: [
                CircleMarker(
                  point: startPoint.toLatLng(),
                  radius: 7.5,
                  color: Theme.of(context).colorScheme.secondary,
                  borderColor: Theme.of(context).colorScheme.onSecondary,
                  borderStrokeWidth: 5.0,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
