import 'package:flutter/material.dart';
import 'package:movna/presentation/widgets/none_widget.dart';

/// Watches changes in the app's lifecycle and calls the corresponding callback
/// on a lifecycle change.
///
/// See [WidgetsBindingObserver.didChangeAppLifecycleState] for more details on
/// lifecycle change.
class AppLifecycleWatcher extends StatefulWidget {
  const AppLifecycleWatcher({
    super.key,
    this.onAppResumed,
    this.onAppDetached,
    this.onAppPaused,
    this.onAppInactive,
    this.onAppHidden,
    this.child,
  });

  final VoidCallback? onAppResumed;
  final VoidCallback? onAppDetached;
  final VoidCallback? onAppPaused;
  final VoidCallback? onAppInactive;
  final VoidCallback? onAppHidden;
  final Widget? child;

  @override
  State<AppLifecycleWatcher> createState() => _AppLifecycleWatcherState();
}

class _AppLifecycleWatcherState extends State<AppLifecycleWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.onAppResumed?.call();
        break;
      case AppLifecycleState.detached:
        widget.onAppDetached?.call();
        break;
      case AppLifecycleState.paused:
        widget.onAppPaused?.call();
        break;
      case AppLifecycleState.inactive:
        widget.onAppInactive?.call();
        break;
      case AppLifecycleState.hidden:
        widget.onAppHidden?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const NoneWidget();
  }
}
