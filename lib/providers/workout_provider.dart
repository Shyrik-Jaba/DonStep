import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:donstep/models/workout.dart';
import 'package:donstep/services/database_service.dart';
import 'package:donstep/services/location_service.dart';
import 'package:donstep/services/step_counter_service.dart';
import 'package:latlong2/latlong.dart';

class WorkoutProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final LocationService _locationService = LocationService();
  final StepCounterService _stepCounter = StepCounterService();

  Workout? _currentWorkout;
  List<Workout> _workouts = [];
  WorkoutSummary? _summary;
  List<LatLng> _coveragePoints = [];
  bool _isTracking = false;
  StreamSubscription<int>? _stepSub;
  Timer? _timer;
  int _elapsedSeconds = 0;

  Workout? get currentWorkout => _currentWorkout;
  List<Workout> get workouts => _workouts;
  WorkoutSummary? get summary => _summary;
  List<LatLng> get coveragePoints => _coveragePoints;
  bool get isTracking => _isTracking;
  LocationService get locationService => _locationService;
  int get elapsedSeconds => _elapsedSeconds;
  int get currentSteps => _stepCounter.totalSteps;

  Stream<List<Workout>> workoutsStream(String uid) => _db.streamWorkouts(uid);

  Future<void> loadWorkouts(String uid) async {
    _workouts = await _db.getAllWorkouts(uid);
    _summary = await _db.getSummary(uid);
    _coveragePoints = await _db.getAllRoutePoints(uid);
    notifyListeners();
  }

  Future<void> loadCoverage(String uid) async {
    _coveragePoints = await _db.getAllRoutePoints(uid);
    notifyListeners();
  }

  Future<String?> startWorkout(String userId) async {
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) return 'Нет разрешения на геолокацию';

    final uuid = const Uuid().v4();
    _currentWorkout = Workout(
      id: uuid,
      userId: userId,
      startTime: DateTime.now(),
    );

    _stepCounter.reset();
    _stepCounter.start();
    _locationService.startTracking();
    _isTracking = true;
    _elapsedSeconds = 0;

    _stepSub = _stepCounter.stepStream.listen((_) {});
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });

    notifyListeners();
    return null;
  }

  Future<Workout> stopWorkout() async {
    _locationService.stopTracking();
    _stepCounter.stop();
    _isTracking = false;
    _timer?.cancel();
    _stepSub?.cancel();

    final distanceKm = _locationService.calculateDistanceKm();
    final steps = _stepCounter.totalSteps;
    final calories = (0.035 * 70 * (distanceKm * 1000 / 1000 * 60)) + (0.029 * 70 * 0);

    _currentWorkout = _currentWorkout!.copyWith(
      endTime: DateTime.now(),
      distanceKm: distanceKm,
      steps: steps,
      calories: calories,
      route: List.from(_locationService.route),
      routeTimestamps: List.from(_locationService.timestamps),
    );

    await _db.saveWorkout(_currentWorkout!);
    _coveragePoints.addAll(_locationService.route);
    _workouts.insert(0, _currentWorkout!);

    final saved = _currentWorkout!;
    _currentWorkout = null;
    notifyListeners();
    return saved;
  }

  Future<String?> loadActiveWorkout(String userId) async {
    final todays = await _db.getTodaysWorkouts(userId);
    final active = todays.where((w) => w.isActive).toList();
    if (active.isNotEmpty) {
      _currentWorkout = active.first;
      notifyListeners();
    }
    return null;
  }

  Future<void> deleteWorkout(String uid, String workoutId) async {
    await _db.deleteWorkout(uid, workoutId);
    _workouts.removeWhere((w) => w.id == workoutId);
    notifyListeners();
  }

  double calculateDistance(List<LatLng> points) {
    final dist = const Distance();
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += dist(points[i - 1], points[i]);
    }
    return total / 1000;
  }

  @override
  void dispose() {
    _locationService.dispose();
    _stepCounter.dispose();
    _timer?.cancel();
    _stepSub?.cancel();
    super.dispose();
  }
}
