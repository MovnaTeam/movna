import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:injectable/injectable.dart';

@module

/// A module that initializes the [FlutterMapTileCaching] package.
abstract class FlutterMapTileCacheModule {
  static const _mapTileStore = 'mapStore';

  @preResolve
  Future<FMTCStore> get initCache async {
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore(_mapTileStore).manage.create();
    return const FMTCStore(_mapTileStore);
  }

  FMTCTileProvider getTileProvider(FMTCStore cache) {
    return FMTCTileProvider(
      stores: {_mapTileStore: BrowseStoreStrategy.readUpdate},
    );
  }
}
