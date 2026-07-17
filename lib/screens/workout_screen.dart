import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:donstep/config/theme.dart';
import 'package:donstep/providers/workout_provider.dart';
import 'package:donstep/providers/auth_provider.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkoutProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('DonStep'), centerTitle: true),
      body: wp.isTracking ? _buildActiveWorkout(context, wp) : _buildIdle(context, wp, auth),
    );
  }

  Widget _buildIdle(BuildContext context, WorkoutProvider wp, AuthProvider auth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_run, size: 120, color: DonStepColors.lime.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text('Готов к тренировке?', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Нажми старт, чтобы начать отслеживание', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 48),
          SizedBox(
            width: 200,
            height: 200,
            child: FloatingActionButton.large(
              onPressed: () async {
                final uid = auth.user?.uid;
                if (uid != null) {
                  final error = await wp.startWorkout(uid);
                  if (error != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                  }
                }
              },
              backgroundColor: DonStepColors.lime,
              foregroundColor: DonStepColors.black,
              child: const Icon(Icons.play_arrow, size: 64),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkout(BuildContext context, WorkoutProvider wp) {
    final dist = wp.locationService.calculateDistanceKm();
    final pace = dist > 0 ? wp.elapsedSeconds / 60 / dist : 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Text('${wp.elapsedSeconds ~/ 60}:${(wp.elapsedSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: DonStepColors.white)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(context, '${dist.toStringAsFixed(2)} км', 'Дистанция'),
              _statItem(context, '${wp.currentSteps}', 'Шаги'),
              _statItem(context, '${pace.toStringAsFixed(1)} мин/км', 'Темп'),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 200,
            height: 200,
            child: FloatingActionButton.large(
              onPressed: () async {
                await wp.stopWorkout();
              },
              backgroundColor: Colors.red,
              foregroundColor: DonStepColors.white,
              child: const Icon(Icons.stop, size: 64),
            ),
          ),
          const SizedBox(height: 24),
          Text('Нажми СТОП, чтобы завершить', style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: DonStepColors.lime)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
