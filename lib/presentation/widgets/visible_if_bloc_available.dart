import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/presentation/widgets/none_widget.dart';

/// A widget that makes [child] only visible if some [ConcreteBloc] is available
/// in the context.
///
/// An optional [fallbackChild] may be provided for when the bloc is
/// unavailable.
class VisibleIfBlocAvailable<ConcreteBloc extends BlocBase>
    extends StatelessWidget {
  const VisibleIfBlocAvailable(
      {required this.child, this.fallbackChild, super.key});

  final Widget child;
  final Widget? fallbackChild;

  @override
  Widget build(BuildContext context) {
    return context
                .findAncestorWidgetOfExactType<BlocProvider<ConcreteBloc>>() !=
            null
        ? child
        : (fallbackChild ?? const NoneWidget());
  }
}
