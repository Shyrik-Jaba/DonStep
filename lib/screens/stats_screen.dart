import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:donstep/config/theme.dart';
import 'package:donstep/providers/workout_provider.dart';
import 'package:donstep/providers/auth_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      context.read<WorkoutProvider>().loadWorkouts(auth.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkoutProvider>();
    final summary = wp.summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика'), centerTitle: true),
      body: summary == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryGrid(summary),
                  const SizedBox(height: 24),
                  Text('Общая дистанция по тренировкам',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: wp.workouts.isEmpty
                        ? const Center(child: Text('Нет данных'))
                        : _buildBarChart(wp),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryGrid(dynamic summary) {
    return Row(
      children: [
        _summaryCard('${summary.totalWorkouts}', 'Тренировок'),
        _summaryCard('${summary.totalSteps}', 'Шагов'),
        _summaryCard('${summary.totalDistanceKm.toStringAsFixed(1)} км', 'Дистанция'),
        _summaryCard('${summary.totalCalories.toStringAsFixed(0)} ккал', 'Калории'),
      ],
    );
  }

  Widget _summaryCard(String value, String label) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: DonStepColors.lime)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11, color: DonStepColors.mediumGray)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(WorkoutProvider wp) {
    final workouts = wp.workouts.take(7).toList();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: workouts.fold(0.0, (m, w) => w.distanceKm > m ? w.distanceKm : m) * 1.2,
        barGroups: workouts.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.distanceKm,
                color: DonStepColors.lime,
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                if (v.toInt() < workouts.length) {
                  final d = workouts[v.toInt()].startTime;
                  return Text('${d.day}.${d.month}',
                      style: const TextStyle(fontSize: 10, color: DonStepColors.mediumGray));
                }
                return const Text('');
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
