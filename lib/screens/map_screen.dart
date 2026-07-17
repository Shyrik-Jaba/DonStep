import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:donstep/config/constants.dart';
import 'package:donstep/config/theme.dart';
import 'package:donstep/providers/workout_provider.dart';
import 'package:donstep/providers/auth_provider.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkoutProvider>();
    final auth = context.watch<AuthProvider>();

    final todayRoute = wp.currentWorkout?.route ?? [];
    final coveragePoints = wp.coveragePoints;

    if (auth.isLoggedIn && coveragePoints.isEmpty && todayRoute.isEmpty) {
      context.read<WorkoutProvider>().loadCoverage(auth.user!.uid);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Карта покрытия'), centerTitle: true),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: coveragePoints.isNotEmpty
              ? coveragePoints.first
              : const LatLng(48.0, 37.8),
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: AppConstants.mapTileUrl,
            userAgentPackageName: 'com.donstep.app',
          ),
          if (todayRoute.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: todayRoute,
                  color: DonStepColors.lime,
                  strokeWidth: 4,
                ),
              ],
            ),
          if (coveragePoints.isNotEmpty)
            CircleLayer(
              circles: coveragePoints.map((p) => CircleMarker(
                point: p,
                color: DonStepColors.lime.withOpacity(0.3),
                borderColor: DonStepColors.lime.withOpacity(0.1),
                borderStrokeWidth: 1,
                radius: 8,
              )).toList(),
            ),
          if (todayRoute.isNotEmpty)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: todayRoute.last,
                  color: Colors.red,
                  radius: 6,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
