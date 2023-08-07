import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_config.freezed.dart';

@freezed
class NotificationConfig with _$NotificationConfig {
  const factory NotificationConfig({
    required String title,
    required String text,
  }) = _NotificationConfig;
}
