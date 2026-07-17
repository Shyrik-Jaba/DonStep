import 'dart:async';
import 'package:pedometer/pedometer.dart';

class StepCounterService {
  StreamSubscription<StepCount>? _subscription;
  int _totalSteps = 0;
  int _baseSteps = 0;
  bool _initialized = false;

  int get totalSteps => _totalSteps;

  Stream<int> get stepStream => _stepController.stream;
  final StreamController<int> _stepController = StreamController<int>.broadcast();

  void start() {
    _subscription = Pedometer.stepCountStream.listen((stepCount) {
      final steps = stepCount.steps;
      if (!_initialized) {
        _baseSteps = steps;
        _initialized = true;
      }
      _totalSteps = steps - _baseSteps;
      _stepController.add(_totalSteps);
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void reset() {
    _totalSteps = 0;
    _baseSteps = 0;
    _initialized = false;
  }

  void dispose() {
    stop();
    _stepController.close();
  }
}
