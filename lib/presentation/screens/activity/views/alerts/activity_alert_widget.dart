import 'package:flutter/material.dart';

/// This widget displays an alert card displaying user
/// information.
///
/// It displays a [title] and [body] that should inform the user of what
/// requires their attention.
///
/// An [icon] must be provided along with an [iconForeground] and
/// [iconBackground] to quickly inform the user of the nature of this
/// alert.
///
/// An optional [action] can be set if user input is needed.
class ActivityAlertWidget extends StatelessWidget {
  const ActivityAlertWidget({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconBackground,
    required this.iconForeground,
    super.key,
    this.action,
  });

  final String title;
  final String body;
  final Widget? action;

  /// An [IconData] of color [iconForeground] displayed in a container with
  /// [iconBackground] color at the left of the card.
  final IconData icon;

  /// Color of the container the [icon] will be drawn on.
  final Color iconBackground;

  /// Color of the [icon].
  final Color iconForeground;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          children: [
            ColoredBox(
              color: iconBackground,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconForeground,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: action,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
