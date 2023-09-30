import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:movna/assets.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/router/router.dart';
import 'package:movna/presentation/theme/app_theme.dart';
import 'package:movna/presentation/widgets/svg_themed_widget.dart';
import 'package:restart_app/restart_app.dart';

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

/// App containing only an error message, displayed when dependency
/// initialization failed.
class BrokenApp extends StatelessWidget {
  const BrokenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: kDebugMode,
      theme: AppTheme().buildLight(),
      darkTheme: AppTheme().buildDark(),
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
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: SvgThemedWidget(svgAsset: Assets.movnaLogo),
          ),
        ),
        body: Builder(
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            height: constraints.maxHeight / 2,
                            child: const SvgThemedWidget(
                              svgAsset: Assets.broken,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      LocaleKeys.broken_app.label().translate(context),
                      style: Theme.of(context).textTheme.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Restart.restartApp();
                      },
                      child: Text(
                        LocaleKeys.broken_app.button().translate(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
