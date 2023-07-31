import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/presentation/router/router.dart';
import 'package:movna/presentation/themes.dart';

class MovnaApp extends StatelessWidget {
  const MovnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: injector<AppRouter>(),
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
    );
  }
}
