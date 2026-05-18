import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Broadcast stream controller to notify the UI about notification action taps
  static final StreamController<String> _actionController =
      StreamController<String>.broadcast();
  static Stream<String> get notificationActions => _actionController.stream;

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _actionController.add(payload);
        }

        if (payload == 'open_call_screen') {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/patientHomeScreen',
            (route) => false,
          );
        } else {
          // Dashboard routing for others
          try {
            final doctorToken = await AuthStorage.getToken();
            final doctorProfile = await AuthStorage.getProfile();
            if (doctorToken != null && doctorToken.isNotEmpty && doctorProfile != null) {
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/doctorHomeScreen',
                (route) => false,
                arguments: {'profile': doctorProfile, 'token': doctorToken},
              );
              return;
            }

            final userToken = await AuthStorage.getUserToken();
            final userProfile = await AuthStorage.getUserProfile();
            if (userToken != null && userToken.isNotEmpty && userProfile != null) {
              final lastRole = await AuthStorage.getLastRole();
              if (lastRole == 'patient') {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/patientHomeScreen',
                  (route) => false,
                  arguments: {'profile': userProfile, 'token': userToken},
                );
              } else {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/userHomeScreen',
                  (route) => false,
                  arguments: {'profile': userProfile, 'token': userToken},
                );
              }
              return;
            }
          } catch (e) {
            debugPrint('⚠️ Navigation on notification tap failed: $e');
          }
          // Default fallback
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        }
      },
    );

    // Explicitly create notification channels and check permissions for Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        debugPrint('🔔 [NotificationService.initialize] Creating Android notification channels...');
        try {
          const AndroidNotificationChannel remindersChannel = AndroidNotificationChannel(
            'memomate_reminders',
            'MemoMate Reminders',
            description: 'Daily reminders and important setup updates.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          );

          await androidPlugin.createNotificationChannel(remindersChannel);
          debugPrint('🔔 [NotificationService.initialize] Notification channels created successfully.');
        } catch (e) {
          debugPrint('❌ [NotificationService.initialize] Error creating channels: $e');
        }

        // Request POST_NOTIFICATIONS permission (Android 13+)
        debugPrint('🔔 [NotificationService.initialize] Requesting Android 13+ notification permission...');
        try {
          final granted = await androidPlugin.requestNotificationsPermission();
          debugPrint('🔔 [NotificationService.initialize] Android 13+ notification permission result: $granted');
        } catch (e) {
          debugPrint('❌ [NotificationService.initialize] Error requesting notification permission: $e');
        }
      }

      // Check and request Exact Alarm permission (Android 12+) using permission_handler
      debugPrint('🔔 [NotificationService.initialize] Checking Exact Alarm permission status...');
      try {
        final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
        debugPrint('🔔 [NotificationService.initialize] Current Exact Alarm status: $exactAlarmStatus');
        if (exactAlarmStatus.isDenied || exactAlarmStatus.isPermanentlyDenied) {
          debugPrint('🔔 [NotificationService.initialize] Exact Alarm is not granted. Requesting...');
          final requestStatus = await Permission.scheduleExactAlarm.request();
          debugPrint('🔔 [NotificationService.initialize] Exact Alarm request result: $requestStatus');
        }
      } catch (e) {
        debugPrint('❌ [NotificationService.initialize] Error checking/requesting Exact Alarm permission: $e');
      }
    }
  }

  // --- Dynamic Triggers (ID 100) ---
  Future<void> showWelcomeNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'memomate_reminders',
      'MemoMate Reminders',
      channelDescription: 'Daily reminders and important setup updates.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    try {
      await flutterLocalNotificationsPlugin.show(
        100,
        "Let's Explore MemoMate",
        "Welcome to your journey with us! Let's stay connected.",
        details,
        payload: 'dashboard',
      );
      debugPrint('🔔 Welcome notification successfully displayed.');
    } catch (e) {
      debugPrint('❌ Failed to display welcome notification: $e');
    }
  }

  Future<void> showSwitchNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'memomate_reminders',
      'MemoMate Reminders',
      channelDescription: 'Daily reminders and important setup updates.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    try {
      await flutterLocalNotificationsPlugin.show(
        100,
        "Let's Explore MemoMate",
        "Welcome to your journey with us! Let's stay connected.",
        details,
        payload: 'dashboard',
      );
      debugPrint('🔔 Role switch notification successfully displayed.');
    } catch (e) {
      debugPrint('❌ Failed to display role switch notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint("All notifications cancelled.");
  }

  // ─── Caregiver Call Reminders (8× daily) ──────────────────────────────────
  /// Call this once at app start for the Patient role to schedule 8 daily
  /// push notifications encouraging the patient to call their caregiver.
  static Future<void> initAndSchedule() async {
    final service = NotificationService();

    // Request Android 13+ notification permission and Exact Alarm permission explicitly
    if (defaultTargetPlatform == TargetPlatform.android) {
      debugPrint('🔔 [NotificationService.initAndSchedule] Requesting Android 13+ notification permission...');
      try {
        final granted = await service.flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        debugPrint('🔔 [NotificationService.initAndSchedule] Android 13+ notification permission result: $granted');
      } catch (e) {
        debugPrint('❌ [NotificationService.initAndSchedule] Error requesting notification permission: $e');
      }

      debugPrint('🔔 [NotificationService.initAndSchedule] Checking Exact Alarm permission status...');
      try {
        final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
        debugPrint('🔔 [NotificationService.initAndSchedule] Current Exact Alarm status: $exactAlarmStatus');
        if (exactAlarmStatus.isDenied || exactAlarmStatus.isPermanentlyDenied) {
          debugPrint('🔔 [NotificationService.initAndSchedule] Exact Alarm is not granted. Requesting...');
          final requestStatus = await Permission.scheduleExactAlarm.request();
          debugPrint('🔔 [NotificationService.initAndSchedule] Exact Alarm request result: $requestStatus');
        }
      } catch (e) {
        debugPrint('❌ [NotificationService.initAndSchedule] Error checking/requesting Exact Alarm permission: $e');
      }
    }

    await service.scheduleDailyCalls();
    debugPrint('Caregiver call reminders auto-scheduled.');

    // Check first launch to trigger Welcome Notification (ID 100)
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('is_first_time_launch') ?? true;
      if (isFirstLaunch) {
        await service.showWelcomeNotification();
        await prefs.setBool('is_first_time_launch', false);
      }
    } catch (e) {
      debugPrint('❌ [NotificationService.initAndSchedule] Welcome notification setup failed: $e');
    }
  }

  Future<void> scheduleDailyCalls() async {
    // 8 fixed reminder daily times with clean IDs 1-8
    const List<Map<String, dynamic>> callTimes = [
      {'id': 1, 'hour': 12, 'minute': 0},
      {'id': 2, 'hour': 14, 'minute': 0},
      {'id': 3, 'hour': 16, 'minute': 0},
      {'id': 4, 'hour': 18, 'minute': 0},
      {'id': 5, 'hour': 20, 'minute': 0},
      {'id': 6, 'hour': 22, 'minute': 0},
      {'id': 7, 'hour': 8,  'minute': 0},
      {'id': 8, 'hour': 10, 'minute': 0},
    ];

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'memomate_reminders',
      'MemoMate Reminders',
      channelDescription: 'Daily reminders and important setup updates.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    for (final entry in callTimes) {
      final int id = entry['id'] as int;
      final int hour = entry['hour'] as int;
      final int minute = entry['minute'] as int;
      final tz.TZDateTime scheduledTime = _nextInstanceOfDetailedTime(hour, minute);

      debugPrint('🔔 [NotificationService.scheduleDailyCalls] Attempting to schedule reminder ID $id for $scheduledTime...');
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          "Let's speak together! ❤️",
          "Tap here to open MemoMate and call your caregiver now.",
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'open_call_screen',
        );
        debugPrint('🔔 [NotificationService.scheduleDailyCalls] Successfully scheduled reminder ID $id.');
      } catch (e) {
        debugPrint('❌ [NotificationService.scheduleDailyCalls] Failed to schedule reminder ID $id: $e');
      }
    }
    debugPrint('8 daily caregiver call reminders scheduling execution finished.');
  }

  Future<void> cancelCallReminders() async {
    for (int id = 1; id <= 8; id++) {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
    debugPrint('Caregiver call reminders cancelled.');
  }

  // --- Medicine Reminders ---
  Future<void> scheduleMedicineReminders(List<ReminderModel> medicines) async {
    // Cancel existing medicine notifications first (using a range of IDs)
    for (int i = 100; i < 200; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }

    for (int i = 0; i < medicines.length; i++) {
      final medicine = medicines[i];
      // Basic time parsing: expect "HH:mm" or "HH:mm AM/PM"
      try {
        final timeParts = medicine.time.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = 0;
        
        if (timeParts.length > 1) {
          final minPart = timeParts[1].split(' ');
          minute = int.parse(minPart[0]);
          if (minPart.length > 1) {
            final period = minPart[1].toLowerCase();
            if (period == 'pm' && hour < 12) hour += 12;
            if (period == 'am' && hour == 12) hour = 0;
          }
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          100 + i,
          "Medicine Reminder: ${medicine.name}",
          "Time to take ${medicine.dose}",
          _nextInstanceOfDetailedTime(hour, minute),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'memomate_reminders',
              'MemoMate Reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e) {
        debugPrint("Error scheduling notification for ${medicine.name}: $e");
      }
    }
  }

  // --- Game Reminders ---
  Future<void> scheduleDailyGameReminders() async {
    final gameTimes = [
      {'id': 50, 'hour': 13},
      {'id': 51, 'hour': 15},
      {'id': 52, 'hour': 19},
    ];

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'memomate_reminders',
      'MemoMate Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    for (final entry in gameTimes) {
      final int id = entry['id'] as int;
      final int hour = entry['hour'] as int;
      
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          "Brain Exercise Time!",
          "Keep your mind sharp with a quick game.",
          _nextInstanceOfDetailedTime(hour, 0),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'open_games_list',
        );
        debugPrint('🔔 Scheduled game reminder ID $id for $hour:00.');
      } catch (e) {
        debugPrint('❌ Failed to schedule game reminder ID $id: $e');
      }
    }
    debugPrint("Daily game reminders scheduled.");
  }

  Future<void> cancelGameReminders() async {
    for (int id = 50; id <= 52; id++) {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
    debugPrint("Game reminders cancelled.");
  }

  tz.TZDateTime _nextInstanceOfTime(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfDetailedTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}