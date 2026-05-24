import 'package:geolocator/geolocator.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:dio/dio.dart';
import 'package:gradproj/core/api/endpoints.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:ui';

class LocationService {
  LocationService._();

  static Future<void> initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'patient_location_channel', // id
      'Location Tracking', // title
      description: 'This channel is used for background location tracking.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'patient_location_channel',
        initialNotificationTitle: 'Memomate',
        initialNotificationContent: 'Tracking location for your safety',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  static Future<Position?> determineCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      debugPrint("Geolocator timeout or error: $e");
      // Fallback to last known position
      return await Geolocator.getLastKnownPosition();
    }
  }

  static Future<Position?> getCurrentPositionBackground() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return null; // NEVER request permissions in the background isolate!
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      debugPrint("Background geolocator error: $e");
      return await Geolocator.getLastKnownPosition();
    }
  }

  // A helper method to send location silently (useful for foreground/background logic)
  static Future<void> updateLocationSilently(String token) async {
    final role = await AuthStorage.getLastRole();
    if (role != 'patient') return;

    final position = await determineCurrentPosition();
    if (position == null) return;

    try {
      final dio = Dio();
      await dio.put(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.location}',
        data: {'lat': position.latitude, 'lng': position.longitude},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      debugPrint("Silently updated patient location.");
    } catch (e) {
      debugPrint('Silent location update failed: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Run immediately once when started
  await _checkAndSendLocation();

  // Then run periodically every 15 minutes
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    await _checkAndSendLocation();
  });
}

Future<void> _checkAndSendLocation() async {
  final role = await AuthStorage.getLastRole();
  if (role != 'patient') return;

  final token = await AuthStorage.getUserToken();
  if (token == null || token.isEmpty) return;

  final position = await LocationService.getCurrentPositionBackground();
  if (position == null) return;

  try {
    final dio = Dio();
    final response = await dio.put(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.location}',
      data: {'lat': position.latitude, 'lng': position.longitude},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    debugPrint(
      "Background location updated successfully! Response: ${response.statusCode}",
    );
  } catch (e) {
    debugPrint("Background location update failed: $e");
  }
}
