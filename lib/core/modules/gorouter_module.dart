import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import 'package:movna/presentation/router/router.dart';

/// A module that initializes [GoRouter] in dependency injection.
@module
abstract class GoRouterModule {
  GoRouter goRouter() => GoRouter(routes: $appRoutes);
}
