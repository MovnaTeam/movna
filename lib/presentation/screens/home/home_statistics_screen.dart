import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movna/core/injection.dart';
import 'package:movna/presentation/blocs/statistics_cubit.dart';
import 'package:movna/presentation/screens/home/widgets/saved_activities_chart.dart';
import 'package:movna/presentation/screens/home/widgets/saved_activities_list_view.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatisticsCubit>(
      create: (_) => injector(),
      child: StatisticsScreenContent(),
    );
  }
}

class StatisticsScreenContent extends StatefulWidget {
  const StatisticsScreenContent({super.key});

  @override
  State<StatisticsScreenContent> createState() =>
      _StatisticsScreenContentState();
}

class _StatisticsScreenContentState extends State<StatisticsScreenContent>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.list)),
            Tab(icon: Icon(Icons.area_chart)),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SavedActivitiesListView(),
              SavedActivitiesChartView(),
            ],
          ),
        ),
      ],
    );
  }
}
