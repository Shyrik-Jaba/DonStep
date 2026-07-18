import 'dart:async';
import 'package:flutter/services.dart';

class StepCounterService {
  static const _eventChannel = EventChannel('com.donstep.app/steps');
  StreamSubscription<dynamic>? _subscription;
  int _totalSteps = 0;
  int _baseSteps = 0;
  bool _initialized = false;

  int get totalSteps => _totalSteps;

  final StreamController<int> _stepController = StreamController<int>.broadcast();
  Stream<int> get stepStream => _stepController.stream;

  void start() {
    _subscription = _eventChannel.receiveBroadcastStream().listen((steps) {
      final currentSteps = steps as int;
      if (!_initialized) {
        _baseSteps = currentSteps;
        _initialized = true;
      }
      _totalSteps = currentSteps - _baseSteps;
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
