import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movna/app.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/core/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool dependenciesInitialized = false;

  try {
    await configureDependencies();
    dependenciesInitialized = true;
  } catch (e, s) {
    logger.f(
      'Error initializing app dependencies',
      error: e,
      stackTrace: s,
    );
  }

  //Setting SystemUIOverlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  );
  //Setting SystemUIMode
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  if(dependenciesInitialized) {
    runApp(const MovnaApp());
  } else {
    runApp(const BrokenApp());
  }
}
