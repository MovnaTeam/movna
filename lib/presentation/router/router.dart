import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/presentation/pages/home/home_page.dart';

part 'router.g.dart';

@injectable
class AppRouter extends GoRouter {
  AppRouter() : super(routes: $appRoutes);
}

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}
