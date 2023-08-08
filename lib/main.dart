import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movna/app.dart';
import 'package:movna/core/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();

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

  runApp(const MovnaApp());
}
