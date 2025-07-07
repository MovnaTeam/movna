import 'package:flutter/material.dart';
import 'package:movna/assets.dart';
import 'package:movna/presentation/screens/common/widgets/slide_indexed_stack.dart';
import 'package:movna/presentation/screens/common/widgets/svg_themed_widget.dart';
import 'package:movna/presentation/screens/home/home_activity_screen.dart';
import 'package:movna/presentation/screens/home/statistics_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedTab = ValueNotifier(0);
  final destinations = [
    NavigationDestination(icon: Icon(Icons.home), label: 'home'),
    NavigationDestination(icon: Icon(Icons.bar_chart), label: 'progress'),
  ];

  final tabs = [
    HomeActivityScreen(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: SvgThemedWidget(svgAsset: Assets.movnaLogo)),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _selectedTab,
        builder: (context, selectedTab, _) {
          return SlideIndexedStack(
            index: selectedTab,
            duration: Duration(milliseconds: 200),
            children: tabs,
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _selectedTab,
        builder: (context, selectedTab, _) {
          return NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: destinations,
            selectedIndex: _selectedTab.value,
            onDestinationSelected: (value) => _selectedTab.value = value,
            animationDuration: Duration(milliseconds: 200),
          );
        },
      ),
    );
  }
}
