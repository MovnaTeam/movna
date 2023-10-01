import 'package:injectable/injectable.dart';
import 'package:movna/core/logger.dart';
import 'package:movna/domain/faults.dart';
import 'package:movna/domain/repositories/user_repository.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Injectable(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._prefs);

  static const String _kZoomLevel = 'zoom-level';

  final SharedPreferences _prefs;

  @override
  Result<double, Fault> getDefaultZoomLevel() {
    try {
      final value = _prefs.getDouble(_kZoomLevel);
      if (value == null) {
        return const Fault.notFound().toFailure();
      }
      return value.toSuccess();
    } catch (e, s) {
      logger.e(
        'Error getting default zoom level',
        stackTrace: s,
        error: e,
      );
      return const Fault.unknown().toFailure();
    }
  }

  @override
  Future<Result<Unit, Fault>> setDefaultZoomLevel(double level) async {
    try {
      final result = await _prefs.setDouble(_kZoomLevel, level);
      if (result) {
        return unit.toSuccess();
      }
      return const Fault.unknown().toFailure();
    } catch (e, s) {
      logger.e(
        'Error getting default zoom level',
        stackTrace: s,
        error: e,
      );
      return const Fault.unknown().toFailure();
    }
  }
}
