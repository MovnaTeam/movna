import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/utils/message_printer.dart';

/// A class responsible for loading the translations for the device's locale
class AppTranslationFileLoader extends FileTranslationLoader {
  AppTranslationFileLoader({
    required this.defaultLocale,
    super.basePath = 'assets/translations',
    super.useCountryCode,
    super.useScriptCode,
    super.forcedLocale,
    super.decodeStrategies,
  });

  final String defaultLocale;

  @override
  Future<Map> load() async {
    locale = locale ?? await findDeviceLocale();
    MessagePrinter.info('The current locales is $locale');

    return await _loadTranslation(defaultLocale);
  }

  /// Loads a file into [_decodedMap]. Overrides all keys present in both
  /// [_decodedMap] and file
  Future<Map<String, dynamic>> _loadTranslation(String defaultFile) async {
    try {
      return await loadFile(composeFileName()) as Map<String, dynamic>;
    } catch (e) {
      MessagePrinter.debug('Error loading translation $e');
      return _loadTranslationFallback(defaultFile);
    }
  }

  /// Loads the fallback translation, used in case the device locales is not
  /// supported. The fallback translation is the english one
  Future<Map<String, dynamic>> _loadTranslationFallback(String fileName) async {
    try {
      return await loadFile(fileName) as Map<String, dynamic>;
    } catch (e) {
      MessagePrinter.debug('Error loading translation fallback $e');
      return {};
    }
  }
}
