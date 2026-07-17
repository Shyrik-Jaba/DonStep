import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donstep/models/workout.dart';
import 'package:latlong2/latlong.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _workouts(String uid) =>
      _firestore.collection('users').doc(uid).collection('workouts');

  Future<void> saveWorkout(Workout workout) async {
    await _workouts(workout.userId).doc(workout.id).set(workout.toFirestore());
  }

  Future<Workout?> getWorkout(String uid, String workoutId) async {
    final doc = await _workouts(uid).doc(workoutId).get();
    if (!doc.exists) return null;
    return Workout.fromFirestore(doc);
  }

  Stream<List<Workout>> streamWorkouts(String uid) {
    return _workouts(uid)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Workout.fromFirestore(doc)).toList());
  }

  Future<List<Workout>> getTodaysWorkouts(String uid) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final snap = await _workouts(uid)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .get();
    return snap.docs.map((doc) => Workout.fromFirestore(doc)).toList();
  }

  Future<List<Workout>> getAllWorkouts(String uid) async {
    final snap = await _workouts(uid)
        .orderBy('startTime', descending: true)
        .get();
    return snap.docs.map((doc) => Workout.fromFirestore(doc)).toList();
  }

  Future<List<LatLng>> getAllRoutePoints(String uid) async {
    final snap = await _workouts(uid).get();
    final points = <LatLng>[];
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final routeData = (data['route'] as List<dynamic>?)
              ?.map((e) => e as GeoPoint)
              .toList() ??
          [];
      points.addAll(routeData.map((gp) => LatLng(gp.latitude, gp.longitude)));
    }
    return points;
  }

  Future<WorkoutSummary> getSummary(String uid) async {
    final snap = await _workouts(uid).get();
    int totalWorkouts = snap.docs.length;
    int totalSteps = 0;
    double totalDistance = 0;
    double totalCalories = 0;
    Duration totalDuration = Duration.zero;

    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalSteps += data['steps'] as int? ?? 0;
      totalDistance += (data['distanceKm'] as num?)?.toDouble() ?? 0;
      totalCalories += (data['calories'] as num?)?.toDouble() ?? 0;
      final start = (data['startTime'] as Timestamp).toDate();
      final end = (data['endTime'] as Timestamp?)?.toDate();
      if (end != null) {
        totalDuration += end.difference(start);
      }
    }

    return WorkoutSummary(
      totalWorkouts: totalWorkouts,
      totalSteps: totalSteps,
      totalDistanceKm: totalDistance,
      totalDuration: totalDuration,
      totalCalories: totalCalories,
    );
  }

  Future<void> deleteWorkout(String uid, String workoutId) async {
    await _workouts(uid).doc(workoutId).delete();
  }
}
