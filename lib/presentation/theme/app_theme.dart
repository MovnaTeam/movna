import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/assets.dart';

part 'color_scheme.dart';
part 'colors.dart';
part 'text_theme.dart';

@injectable
class AppTheme {
  ThemeData buildLight() {
    return build(Brightness.light);
  }

  ThemeData buildDark() {
    return build(Brightness.dark);
  }

  ThemeData build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: switch (brightness) {
        Brightness.dark => _darkColorScheme,
        Brightness.light => _lightColorScheme,
      },
      fontFamily: Fonts.poppins,
      textTheme: _textTheme,
      extensions: [
        switch (brightness) {
          Brightness.light => _lightCustomColors,
          Brightness.dark => _darkCustomColors,
        },
      ],
    );
  }
}

/// Small set of extensions to easily retrieve [ThemeExtension]s from a theme.
extension ThemeExtensionGetter on ThemeData {
  CustomColors get customColors => extension<CustomColors>()!;
}
