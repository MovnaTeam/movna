import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movna/app.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/domain/usecases/permission_usecases/handle_location_permission.dart';
import 'package:movna/domain/usecases/permission_usecases/handle_notifications_permission.dart';

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

  await injector<HandleNotificationsPermission>()();
  await injector<HandleLocationPermission>()();

  runApp(const MovnaApp());
}
