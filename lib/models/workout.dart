import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Workout {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int steps;
  final double distanceKm;
  final double calories;
  final List<LatLng> route;
  final List<DateTime> routeTimestamps;

  Workout({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.steps = 0,
    this.distanceKm = 0,
    this.calories = 0,
    this.route = const [],
    this.routeTimestamps = const [],
  });

  Duration get duration =>
      (endTime ?? DateTime.now()).difference(startTime);

  double get paceMinPerKm =>
      distanceKm > 0 ? (duration.inMinutes / distanceKm) : 0;

  double get avgSpeedKmh =>
      duration.inHours > 0 ? distanceKm / duration.inHours : 0;

  bool get isActive => endTime == null;

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'steps': steps,
      'distanceKm': distanceKm,
      'calories': calories,
      'route': route
          .map((p) => GeoPoint(p.latitude, p.longitude))
          .toList(),
      'routeTimestamps':
          routeTimestamps.map((t) => Timestamp.fromDate(t)).toList(),
    };
  }

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final routeData = (data['route'] as List<dynamic>?)
            ?.map((e) => e as GeoPoint)
            .toList() ??
        [];
    final tsData = (data['routeTimestamps'] as List<dynamic>?)
            ?.map((e) => (e as Timestamp).toDate())
            .toList() ??
        [];
    return Workout(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      steps: data['steps'] as int? ?? 0,
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0,
      calories: (data['calories'] as num?)?.toDouble() ?? 0,
      route: routeData
          .map((gp) => LatLng(gp.latitude, gp.longitude))
          .toList(),
      routeTimestamps: tsData,
    );
  }

  Workout copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? steps,
    double? distanceKm,
    double? calories,
    List<LatLng>? route,
    List<DateTime>? routeTimestamps,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      calories: calories ?? this.calories,
      route: route ?? this.route,
      routeTimestamps: routeTimestamps ?? this.routeTimestamps,
    );
  }
}

class WorkoutSummary {
  final int totalWorkouts;
  final int totalSteps;
  final double totalDistanceKm;
  final Duration totalDuration;
  final double totalCalories;

  WorkoutSummary({
    this.totalWorkouts = 0,
    this.totalSteps = 0,
    this.totalDistanceKm = 0,
    this.totalDuration = Duration.zero,
    this.totalCalories = 0,
  });
}
