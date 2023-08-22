import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:injectable/injectable.dart';

@module
/// A module that initializes the [FlutterMapTileCaching] package.
abstract class FlutterMapTileCacheModule {
  static const _mapTileStore = 'mapStore';

  @preResolve
  Future<FlutterMapTileCaching> get initCache async {
    await FlutterMapTileCaching.initialise();
    await FMTC.instance(_mapTileStore).manage.createAsync();
    return FMTC.instance;
  }

  FMTCTileProvider getTileProvider(FlutterMapTileCaching cache) {
    return cache(_mapTileStore).getTileProvider();
  }

}
