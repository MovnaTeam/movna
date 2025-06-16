import 'package:flutter/material.dart';
import 'package:movna/assets.dart';
import 'package:movna/jsons.dart';
import 'package:movna/presentation/locale/locales_helper.dart';
import 'package:movna/presentation/router/router.dart';
import 'package:movna/presentation/widgets/svg_themed_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: SvgThemedWidget(svgAsset: Assets.movnaLogo)),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ElevatedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (context) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text(
                      LocaleKeys.home.startActivity().translate(context),
                    ),
                    onPressed: () => const ActivityRoute().go(context),
                  ),
                );
              },
            ),
            child: Text(LocaleKeys.home.startActivity().translate(context)),
          ),
        ),
      ),
    );
  }
}
