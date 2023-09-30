import 'package:flutter/material.dart';
import 'package:movna/assets.dart';
import 'package:movna/presentation/screens/activity/activity_screen.dart';
import 'package:movna/presentation/widgets/svg_themed_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: SvgThemedWidget(svgAsset: Assets.movnaLogo)),
      ),
      body: const SafeArea(
        bottom: false,
        child: ActivityScreen(),
      ),
    );
  }
}
