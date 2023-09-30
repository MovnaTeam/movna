import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/domain/entities/app_metadata.dart';
import 'package:movna/domain/entities/gps_coordinates.dart';
import 'package:movna/domain/usecases/get_last_location.dart';
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

  @override
  void initState() {
    // Get last location and set controller to the given coordinates or to Paris
    injector<GetLastKnownLocation>()().then(
      (value) {
        value.fold(
          (lastLocation) {
            _controller.move(
              lastLocation.location.gpsCoordinates.toLatLng(),
              16,
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
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
        if (location != null) {
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
        ),
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
