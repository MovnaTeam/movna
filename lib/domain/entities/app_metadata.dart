import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_metadata.freezed.dart';

enum AppEnvironment {
  production,
  development,
}

/// Contains useful data about the running app.
@freezed
class AppMetadata with _$AppMetadata {
  const factory AppMetadata({
    required String packageName,
    required AppEnvironment environment,
    required String version,
    required int buildNumber,
  }) = _AppMetadata;


}