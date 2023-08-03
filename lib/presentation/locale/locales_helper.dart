import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:intl/intl.dart';
import 'package:json_locale/json_locale.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/presentation/locale/translation_file_loader.dart';

/// Utils class holding methods related to localized translations of the
/// application
abstract final class AppI18n {
  static Iterable<Locale> get supportedLocales => const [
        Locale.fromSubtags(languageCode: 'fr'),
        Locale.fromSubtags(languageCode: 'en'),
      ];

  /// Returns the locale to use for the app from the user's [preferredLocales]
  /// and the app's [supportedLocales]
  ///
  /// If none of the [preferredLocales] are supported, return `en_US`
  static Locale? localeListResolutionCallback(
    List<Locale>? preferredLocales,
    Iterable<Locale> supportedLocales,
  ) {
    final preferredLocaleLanguageCodes =
        preferredLocales?.map((e) => e.languageCode).toSet() ?? <String>{};
    final supportedLocaleLanguageCodes =
        supportedLocales.map((e) => e.languageCode).toSet();

    // Find the first language both in preferred and supported locales
    final firstCommonLanguageCodes = preferredLocaleLanguageCodes
        .intersection(supportedLocaleLanguageCodes)
        .firstOrNull;

    // Take the language found or fallback to english

    final localeToUse = firstCommonLanguageCodes == null
        ? const Locale.fromSubtags(
            languageCode: 'en',
            countryCode: 'US',
          )
        : Locale.fromSubtags(languageCode: firstCommonLanguageCodes);

    // Set for the datetime formatters
    Intl.defaultLocale = localeToUse.languageCode;
    return localeToUse;
  }

  /// Returns the [LocalizationsDelegate] responsible for the translation
  ///
  /// See [AppTranslationFileLoader] for the class responsible for loading the
  /// appropriate translation for a given [Locale]
  static LocalizationsDelegate<FlutterI18n> get delegate {
    return FlutterI18nDelegate(
      translationLoader: AppTranslationFileLoader(
        defaultLocale: 'en',
        decodeStrategies: [JsonDecodeStrategy()],
        useCountryCode: false,
        basePath: 'assets/translations',
      ),
      missingTranslationHandler: (key, locale) {
        logger.d(
          '--- Missing Key: $key, languageCode: ${locale?.languageCode}',
        );
      },
    );
  }
}

/// Extension to translate a singular string with eventual placeholders
extension LocaleExt on Translatable {
  String translate(BuildContext context) {
    return FlutterI18n.translate(context, key, translationParams: params);
  }
}

/// Extension to translate a plural string
extension LocalePluralExt on TranslatablePlural {
  String translate(BuildContext context) {
    return FlutterI18n.plural(context, key, cardinality);
  }
}
