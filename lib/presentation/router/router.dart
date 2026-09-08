import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movna/presentation/screens/home/home_page.dart';
import 'package:movna/presentation/screens/past_activity/past_activity_page.dart';

part 'router.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData with $HomeRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

@TypedGoRoute<PastActivityRoute>(path: '/activity/:id')
class PastActivityRoute extends GoRouteData with $PastActivityRoute {
  const PastActivityRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PastActivityPage(activityId: id);
  }
}
