import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/domain/entities/app_metadata.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/usecases/get_default_zoom_level.dart';
import 'package:movna/domain/usecases/get_last_location.dart';
import 'package:movna/domain/usecases/set_default_zoom_level.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';
import 'package:movna/presentation/extensions/gps_coordinates_extensions.dart';
import 'package:movna/presentation/screens/common/views/map/constants.dart';
import 'package:movna/presentation/screens/common/views/map/widgets/activity_map_layer.dart';
import 'package:movna/presentation/screens/common/views/map/widgets/user_location_marker.dart';
import 'package:movna/presentation/screens/common/widgets/loading_indicator.dart';
import 'package:movna/presentation/screens/common/widgets/none_widget.dart';
import 'package:movna/presentation/screens/common/widgets/visible_if_bloc_available.dart';

/// Displays a map with location information about the current activity.
///
/// Initializes the map at the last known location using [GetLastKnownLocation]
/// or to [GpsCoordinates.paris] if no previous location could be found.
class ActivityMapView extends StatefulWidget {
  const ActivityMapView({super.key});

  @override
  State<ActivityMapView> createState() => _ActivityMapViewState();
}

/// How the map should follow user movements.
enum FollowUserBehavior {
  /// Do not follow user.
  disabled,

  /// Only follow use location.
  location,

  /// Follow user location and heading direction.
  locationRotation,
}

class _ActivityMapViewState extends State<ActivityMapView>
    with TickerProviderStateMixin {
  /// Controller use to modify and animate the [FlutterMap].
  late final _controller = AnimatedMapController(
    vsync: this,
    duration: MapConstants.mapAnimationsDuration,
    curve: MapConstants.mapAnimationsCurve,
  );

  /// This determines whether the map should follow user location and heading
  /// direction.
  ///
  /// If value is `disabled`, location updates will move the marker but not the
  /// map view.
  /// If value is `location`, location updates will move the marker on the map
  /// and the map view will move to be centered on the marker.
  /// If value is `locationRotation`, location updates will move the marker on
  /// the map and the map view will move to be centered on the marker and
  /// rotation so that the user heading direction is up.
  final ValueNotifier<FollowUserBehavior> _followUserBehavior =
      ValueNotifier(FollowUserBehavior.location);

  /// The last known location, used to center map immediately when user clicks
  /// on the center button
  Location? _lastLocation;

  /// Last used zoom level, particularly handy on first render.
  late double _zoomLevel;

  /// Subscription to the [_controller.mapEventStream].
  late StreamSubscription<MapEvent> _mapEventSubscription;

  @override
  void initState() {
    _zoomLevel = injector<GetDefaultZoomLevel>()()
        .getOrDefault(MapConstants.defaultZoom);

    // Listen to map events to detect user gestures
    _mapEventSubscription = _controller.mapController.mapEventStream.listen(
      (event) {
        // Update flags if user starts certain gestures
        if (event is MapEventFlingAnimationStart ||
            event is MapEventMoveStart ||
            event is MapEventDoubleTapZoomStart ||
            event is MapEventRotateStart) {
          _followUserBehavior.value = FollowUserBehavior.disabled;
        }

        if (event is MapEventDoubleTapZoomEnd ||
            event is MapEventMoveEnd ||
            event is MapEventScrollWheelZoom) {
          _zoomLevel = event.camera.zoom;
          injector<SetDefaultZoomLevel>()(_zoomLevel);
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _mapEventSubscription.cancel();
    _followUserBehavior.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationCubit, LocationCubitState>(
      listener: (context, state) {
        // Listen to location changes and animate the map to the location
        // (do not change zoom level)
        final timedLocation = switch (state) {
          LocationCubitStateLoading(:final lastKnownLocation) =>
            lastKnownLocation,
          LocationCubitStateLoaded(:final currentLocation) => currentLocation,
          _ => null,
        };
        if (timedLocation == null) return;

        _lastLocation = timedLocation.location;
        final destination =
            _followUserBehavior.value != FollowUserBehavior.disabled
                ? timedLocation.location.gpsCoordinates.toLatLng()
                : null;
        final orientation =
            _followUserBehavior.value == FollowUserBehavior.locationRotation
                ? -timedLocation.location.headingInDegrees
                : null;
        _controller.animateTo(
          dest: destination,
          rotation: orientation,
        );
      },
      child: FlutterMap(
        mapController: _controller.mapController,
        options: MapOptions(
          initialCenter: GpsCoordinates.paris.toLatLng(),
          initialZoom: _zoomLevel,
          maxZoom: MapConstants.maxZoom,
          interactionOptions: const InteractionOptions(
            enableMultiFingerGestureRace: true,
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        children: [
          // Actual map layer
          TileLayer(
            errorTileCallback: (tile, error, stackTrace) => logger.e(
              'Error getting map tile',
              error: error,
              stackTrace: stackTrace,
            ),
            urlTemplate: MapConstants.urlTemplate,
            userAgentPackageName: injector<AppMetadata>().packageName,
            tileProvider: injector<FMTCTileProvider>(),
            tileBuilder: switch (Theme.of(context).brightness) {
              Brightness.dark => darkModeTileBuilder,
              Brightness.light => null,
            },
          ),
          const VisibleIfBlocAvailable<ActivityCubit>(
            child: ActivityMapLayer(),
          ),
          // User Marker layer
          const VisibleIfBlocAvailable<LocationCubit>(
            child: UserLocationMarker(),
          ),
          // Loading indicator layer.
          BlocBuilder<LocationCubit, LocationCubitState>(
            buildWhen: (prev, next) => prev.runtimeType != next.runtimeType,
            builder: (context, state) {
              return switch (state) {
                LocationCubitStateInitial() ||
                LocationCubitStateLoading() =>
                  const Center(child: LoadingIndicator()),
                _ => const NoneWidget(),
              };
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildMapFollowUserFloatingActionButtons(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFollowUserFloatingActionButtons(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _followUserBehavior,
      builder: (context, followUserBehavior, _) {
        if (followUserBehavior == FollowUserBehavior.locationRotation) {
          return const NoneWidget();
        }

        return switch (followUserBehavior) {
          FollowUserBehavior.disabled => FloatingActionButton.small(
              onPressed: () {
                final location = _lastLocation;
                if (location != null) {
                  _followUserBehavior.value = FollowUserBehavior.location;
                  _controller.animateTo(
                    dest: location.gpsCoordinates.toLatLng(),
                  );
                }
              },
              child: const Icon(Icons.my_location),
            ),
          FollowUserBehavior.location => FloatingActionButton.small(
              onPressed: () {
                final location = _lastLocation;
                if (location != null) {
                  _followUserBehavior.value =
                      FollowUserBehavior.locationRotation;
                  _controller.animateTo(
                    dest: location.gpsCoordinates.toLatLng(),
                    rotation: -location.headingInDegrees,
                  );
                }
              },
              child: const Icon(Icons.navigation),
            ),
          _ => NoneWidget(),
        };
      },
    );
  }
}
