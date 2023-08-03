import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/router/router.dart';
import 'package:movna/presentation/theme/app_theme.dart';

class MovnaApp extends StatelessWidget {
  const MovnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: injector<AppRouter>(),
      debugShowCheckedModeBanner: kDebugMode,
      theme: injector<AppTheme>().buildLight(),
      darkTheme: injector<AppTheme>().buildDark(),
      supportedLocales: AppI18n.supportedLocales,
      onGenerateTitle: (context) {
        return LocaleKeys.appTitle().translate(context);
      },
      localizationsDelegates: [
        AppI18n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
