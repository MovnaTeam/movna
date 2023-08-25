part of 'app_theme.dart';

// Generated using https://m3.material.io/theme-builder#/custom
const _warning = Color(0xFFFF904B);

CustomColors _lightCustomColors = const CustomColors(
  sourceWarning: _warning,
  warning: Color(0xFF9B4500),
  onWarning: Color(0xFFFFFFFF),
  warningContainer: Color(0xFFFFDBC9),
  onWarningContainer: Color(0xFF331200),
);

CustomColors _darkCustomColors = const CustomColors(
  sourceWarning: _warning,
  warning: Color(0xFFFFB68D),
  onWarning: Color(0xFF532200),
  warningContainer: Color(0xFF763300),
  onWarningContainer: Color(0xFFFFDBC9),
);

/// Defines a set of custom colors, each comprised of 4 complementary tones.
///
/// See also:
///   * <https://m3.material.io/styles/color/the-color-system/custom-colors>
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.sourceWarning,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  final Color sourceWarning;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  @override
  CustomColors copyWith({
    Color? sourceWarning,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return CustomColors(
      sourceWarning: sourceWarning ?? this.sourceWarning,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      sourceWarning: Color.lerp(
        sourceWarning,
        other.sourceWarning,
        t,
      )!,
      warning: Color.lerp(
        warning,
        other.warning,
        t,
      )!,
      onWarning: Color.lerp(
        onWarning,
        other.onWarning,
        t,
      )!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
    );
  }
}
