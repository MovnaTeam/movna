import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movna/assets.dart';
import 'package:movna/presentation/screens/activity/activity_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: SvgPicture.asset(Assets.movnaLogo)),
      ),
      body: const SafeArea(
        bottom: false,
        child: ActivityScreen(),
      ),
    );
  }
}
