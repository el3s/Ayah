import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme.dart';
import '../services/location_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final LocationService _locationService = LocationService();
  double? _qiblaDirection;
  String? _error;

  // إحداثيات الكعبة المشرفة
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _computeQibla();
  }

  Future<void> _computeQibla() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) return;
      final bearing = _calculateBearing(
        position.latitude,
        position.longitude,
        _kaabaLat,
        _kaabaLng,
      );
      setState(() => _qiblaDirection = bearing);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  double _calculateBearing(double lat1, double lng1, double lat2, double lng2) {
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaLambda = (lng2 - lng1) * pi / 180;

    final y = sin(deltaLambda) * cos(phi2);
    final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);
    final theta = atan2(y, x);
    return (theta * 180 / pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اتجاه القبلة')),
      body: _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)))
          : _qiblaDirection == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('البوصلة غير متوفرة على هذا الجهاز'));
                    }
                    final heading = snapshot.data!.heading ?? 0;
                    final angle = ((_qiblaDirection! - heading) * pi / 180);

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: angle,
                            child: const Icon(Icons.navigation_rounded,
                                size: 160, color: AppColors.gold),
                          ),
                          const SizedBox(height: 24),
                          const Text('وجّه الهاتف نحو السهم لمعرفة اتجاه القبلة',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
