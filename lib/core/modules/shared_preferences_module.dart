import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A module that initializes [SharedPreferences] in dependency injection.
@module
abstract class SharedPreferencesModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences {
    return SharedPreferences.getInstance();
  }
}