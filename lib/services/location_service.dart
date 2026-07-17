import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:donstep/config/constants.dart';

class LocationService {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  final List<LatLng> _route = [];
  final List<DateTime> _timestamps = [];
  final Distance _distance = const Distance();

  List<LatLng> get route => List.unmodifiable(_route);
  List<DateTime> get timestamps => List.unmodifiable(_timestamps);
  Position? get currentPosition => _currentPosition;

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConstants.gpsDistanceFilterMeters,
      ),
    );
  }

  void startTracking() {
    _route.clear();
    _timestamps.clear();
    _positionSubscription = getPositionStream().listen((position) {
      _currentPosition = position;
      final point = LatLng(position.latitude, position.longitude);
      if (_route.isEmpty ||
          _distance(_route.last, point) >= AppConstants.minDistanceForNewPoint) {
        _route.add(point);
        _timestamps.add(DateTime.now());
      }
    });
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  double calculateDistanceKm() {
    double total = 0;
    for (int i = 1; i < _route.length; i++) {
      total += _distance(_route[i - 1], _route[i]);
    }
    return total / 1000;
  }

  void dispose() {
    stopTracking();
  }
}
