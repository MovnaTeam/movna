import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/assets.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/blocs/location_cubit.dart';
import 'package:movna/presentation/blocs/location_service_cubit.dart';
import 'package:movna/presentation/blocs/permissions_cubit.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/screens/common/views/map/activity_map_view.dart';
import 'package:movna/presentation/screens/common/widgets/none_widget.dart';
import 'package:movna/presentation/screens/common/widgets/svg_themed_widget.dart';
import 'package:movna/presentation/screens/home/start_activity_popup.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: SvgThemedWidget(svgAsset: Assets.movnaLogo)),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _buildMapWidget(context),
            SafeArea(
              bottom: true,
              child: Column(
                children: [
                  Expanded(child: const NoneWidget()),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        builder: (context) => const StartActivityPopup(),
                      ),
                      child: Text(
                        LocaleKeys.home.startActivity().translate(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapWidget(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationServiceCubit>(
          create: (_) => injector(),
        ),
        BlocProvider<PermissionsCubit>(
          lazy: false,
          create: (_) {
            return injector(
              param1: const PermissionsCubitParams(
                requestLocation: true,
                requestNotifications: true,
              ),
            )..requestPermissions();
          },
        ),
        BlocProvider<LocationCubit>(
          lazy: false,
          create: (providerContext) {
            return injector(
              param1: LocationCubitParams(
                permissionsCubit: providerContext.read<PermissionsCubit>(),
                locationServiceCubit:
                    providerContext.read<LocationServiceCubit>(),
              ),
            )..listenToLocation();
          },
        ),
      ],
      child: const ActivityMapView(),
    );
  }
}
