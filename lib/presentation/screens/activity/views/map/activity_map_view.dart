import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/domain/entities/app_metadata.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';
import 'package:movna/domain/entities/location.dart';
import 'package:movna/domain/usecases/get_default_zoom_level.dart';
import 'package:movna/domain/usecases/get_last_location.dart';
import 'package:movna/domain/usecases/set_default_zoom_level.dart';
import 'package:movna/presentation/blocs/activity_cubit.dart';
import 'package:movna/presentation/extensions/gps_coordinates_extensions.dart';
import 'package:movna/presentation/screens/activity/views/map/constants.dart';
import 'package:movna/presentation/screens/activity/views/map/widgets/user_location_marker.dart';
import 'package:movna/presentation/widgets/loading_indicator.dart';
import 'package:movna/presentation/widgets/none_widget.dart';

/// Displays a map with location information about the current activity.
///
/// Initializes the map at the last known location using [GetLastKnownLocation]
/// or to [GpsCoordinates.paris] if no previous location could be found.
class ActivityMapView extends StatefulWidget {
  const ActivityMapView({super.key});

  @override
  State<ActivityMapView> createState() => _ActivityMapViewState();
}

class _ActivityMapViewState extends State<ActivityMapView>
    with TickerProviderStateMixin {
  /// Controller use to modify and animate the [FlutterMap].
  late final _controller = AnimatedMapController(
    vsync: this,
    duration: MapConstants.mapAnimationsDuration,
    curve: MapConstants.mapAnimationsCurve,
  );

  /// This determines wether the map should be centered on location.
  ///
  /// If value is `false`, location updates will move the marker but not the map
  /// view.
  /// If value is `true`, location updates will move the marker on the map and
  /// the map view will move to be centered on the marker.
  final ValueNotifier<bool> _centerOnLocation = ValueNotifier(true);

  /// The last known location, used to center map immediately when user clicks
  /// on the center button
  Location? _lastLocation;

  /// Subscription to the [_controller.mapEventStream].
  late StreamSubscription<MapEvent> _mapEventSubscription;

  @override
  void initState() {
    final zoomLevelResult = injector<GetDefaultZoomLevel>()();
    // Get last location and set controller to the given coordinates or to Paris
    injector<GetLastKnownLocation>()().then(
      (value) {
        value.fold(
          (lastLocation) {
            _lastLocation = lastLocation.location;
            _controller.move(
              lastLocation.location.gpsCoordinates.toLatLng(),
              zoomLevelResult.getOrDefault(16),
            );
          },
          (f) {
            _controller.move(
              GpsCoordinates.paris.toLatLng(),
              6,
            );
          },
        );
      },
    );

    // Listen to map events to detect user gestures
    _mapEventSubscription = _controller.mapEventStream.listen(
      (event) {
        // Update center on location flag if user starts certain gestures
        _centerOnLocation.value = switch (event) {
          MapEventFlingAnimationStart() ||
          MapEventMoveStart() ||
          MapEventDoubleTapZoomStart() ||
          MapEventRotateStart() =>
            false,
          _ => _centerOnLocation.value,
        };
        if (event is MapEventDoubleTapZoomEnd ||
            event is MapEventMoveEnd ||
            event is MapEventScrollWheelZoom) {
          injector<SetDefaultZoomLevel>()(event.zoom);
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _mapEventSubscription.cancel();
    _centerOnLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityCubit, ActivityState>(
      listener: (context, state) {
        // Listen to location changes and animate the map to the location
        // (do not change zoom level)
        final location =
            state.mapOrNull(loaded: (loaded) => loaded.currentLocation);
        if (location != null && _centerOnLocation.value) {
          _lastLocation = location;
          _controller.animateTo(
            dest: location.gpsCoordinates.toLatLng(),
          );
        }
      },
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          center: GpsCoordinates.paris.toLatLng(),
          zoom: 6,
          maxZoom: MapConstants.maxZoom,
          enableMultiFingerGestureRace: true,
        ),
        nonRotatedChildren: [
          ValueListenableBuilder(
            valueListenable: _centerOnLocation,
            builder: (context, centerOnLocation, fab) {
              if (centerOnLocation) {
                return const NoneWidget();
              }
              return fab!;
            },
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton.small(
                  onPressed: () {
                    final location = _lastLocation;
                    if (location != null) {
                      _centerOnLocation.value = true;
                      _controller.animateTo(
                        dest: location.gpsCoordinates.toLatLng(),
                      );
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
            ),
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: MapConstants.urlTemplate,
            userAgentPackageName: injector<AppMetadata>().packageName,
            tileProvider: injector<FMTCTileProvider>(),
            tileBuilder: switch (Theme.of(context).brightness) {
              Brightness.dark => darkModeTileBuilder,
              Brightness.light => null,
            },
            backgroundColor: Theme.of(context).colorScheme.background,
          ),
          const UserLocationMarker<ActivityCubit, ActivityState>(),
          BlocBuilder<ActivityCubit, ActivityState>(
            buildWhen: (prev, next) => prev.runtimeType != next.runtimeType,
            builder: (context, state) {
              return state.maybeMap(
                loading: (_) => const Center(
                  child: LoadingIndicator(),
                ),
                orElse: () => const NoneWidget(),
              );
            },
          ),
        ],
      ),
    );
  }
}
