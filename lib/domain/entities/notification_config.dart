import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_config.freezed.dart';

/// Configuration for a notification, contains the notification's title and body
@freezed
abstract class NotificationConfig with _$NotificationConfig {
  const factory NotificationConfig({
    required String title,
    required String text,
  }) = _NotificationConfig;
}
