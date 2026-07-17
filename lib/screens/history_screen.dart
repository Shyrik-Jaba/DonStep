import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:donstep/config/theme.dart';
import 'package:donstep/providers/workout_provider.dart';
import 'package:donstep/providers/auth_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      context.read<WorkoutProvider>().loadWorkouts(auth.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('История'), centerTitle: true),
      body: wp.workouts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: DonStepColors.mediumGray),
                  const SizedBox(height: 16),
                  Text('Тренировок пока нет', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wp.workouts.length,
              itemBuilder: (_, i) => _buildWorkoutCard(context, wp.workouts[i]),
            ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, dynamic workout) {
    final date = DateFormat('dd.MM.yyyy HH:mm').format(workout.startTime);
    final dur = workout.duration;
    final durStr = '${dur.inHours}ч ${dur.inMinutes.remainder(60)}мин';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: DonStepColors.lime.withOpacity(0.2),
          child: const Icon(Icons.directions_run, color: DonStepColors.lime),
        ),
        title: Text(date, style: const TextStyle(color: DonStepColors.white)),
        subtitle: Text(
          '${workout.distanceKm.toStringAsFixed(2)} км  |  $durStr  |  ${workout.steps} шагов',
          style: const TextStyle(color: DonStepColors.mediumGray),
        ),
        trailing: Text(
          '${workout.calories.toStringAsFixed(0)} ккал',
          style: const TextStyle(color: DonStepColors.lime),
        ),
      ),
    );
  }
}
