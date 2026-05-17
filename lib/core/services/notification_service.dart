import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';
import 'package:permission_handler/permission_handler.dart';


class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload == 'game_reminder') {
          // Navigate to games tab – handled at screen level
        } else if (payload == 'open_call_screen') {
          // Navigate to the patient home screen (tab 0 = home where Call Me lives)
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/patientHomeScreen',
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
          const AndroidNotificationChannel caregiverChannel = AndroidNotificationChannel(
            'caregiver_reminder_channel',
            'Caregiver Reminders',
            description: 'Daily reminders for the patient to call their caregiver.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          );

          const AndroidNotificationChannel gameChannel = AndroidNotificationChannel(
            'game_reminder_channel',
            'Game Reminders',
            description: 'Daily reminders to play brain exercises.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          );

          const AndroidNotificationChannel medicineChannel = AndroidNotificationChannel(
            'medicine_reminder_channel',
            'Medicine Reminders',
            description: 'Daily reminders for medication.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          );

          const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
            'daily_reminder_channel',
            'Daily Reminders',
            description: 'Testing and other daily notifications.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          );

          await androidPlugin.createNotificationChannel(caregiverChannel);
          await androidPlugin.createNotificationChannel(gameChannel);
          await androidPlugin.createNotificationChannel(medicineChannel);
          await androidPlugin.createNotificationChannel(dailyChannel);
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


  // Verification test
  Future<void> showInstantTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_channel',
          'Instant Test',
          channelDescription: 'Testing if notifications work',
          importance: Importance.max,
          priority: Priority.high,
        );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notification Test',
      'System is working! Scheduled alerts set for 10am, 3pm, 7pm.',
      const NotificationDetails(android: androidDetails),
    );
  }

  // The 3 daily reminders
  Future<void> scheduleDailyReminders() async {
    await _scheduleNotification(
      1,
      "Morning Brain Exercise",
      "Time for your 10 AM memory game!",
      10,
    );
    await _scheduleNotification(
      2,
      "Afternoon Challenge",
      "Boost your focus with a quick game!",
      15,
    );
    await _scheduleNotification(
      3,
      "Evening Routine",
      "Don't forget your daily memory training!",
      19,
    );
    debugPrint("All 3 notifications have been scheduled.");
  }

  Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    int hour,
  ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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

    // ── Schedule 1-minute Active Test Notification (ID 999) on app startup ──
    try {
      await service.scheduleTestNotification();
    } catch (e) {
      debugPrint('❌ [NotificationService.initAndSchedule] Startup test notification scheduling failed: $e');
    }
  }

  Future<void> scheduleTestNotification() async {
    // ── One-time 1-minute TEST notification (fires 1 min from now) ──────────────
    final tz.TZDateTime testTime =
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

    const AndroidNotificationDetails testAndroidDetails =
        AndroidNotificationDetails(
      'caregiver_reminder_channel',
      'Caregiver Reminders',
      channelDescription:
          'Daily reminders for the patient to call their caregiver.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails testDetails =
        NotificationDetails(android: testAndroidDetails);

    try {
      debugPrint('🔔 [NotificationService.scheduleTestNotification] Scheduling 1-minute Test Notification (ID 999) for $testTime...');
      await flutterLocalNotificationsPlugin.zonedSchedule(
        999,
        'MemoMate is Active! ✅',
        'The system is successfully monitoring your daily schedule.',
        testTime,
        testDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('🔔 [NotificationService.scheduleTestNotification] 1-minute Test Notification successfully scheduled.');
    } catch (e) {
      debugPrint('❌ [NotificationService.scheduleTestNotification] Failed to schedule 1-minute Test Notification: $e');
    }
  }

  Future<void> scheduleDailyCalls() async {
    // Use IDs 201–208 to avoid collision with medicine (100-199) and game (50) notifications
    const List<Map<String, dynamic>> callTimes = [
      {'id': 201, 'hour': 9,  'minute': 0},
      {'id': 202, 'hour': 11, 'minute': 0},
      {'id': 203, 'hour': 13, 'minute': 0},
      {'id': 204, 'hour': 15, 'minute': 0},
      {'id': 205, 'hour': 17, 'minute': 0},
      {'id': 206, 'hour': 19, 'minute': 0},
      {'id': 207, 'hour': 21, 'minute': 0},
      {'id': 208, 'hour': 22, 'minute': 30},
    ];

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'caregiver_reminder_channel',
      'Caregiver Reminders',
      channelDescription:
          'Daily reminders for the patient to call their caregiver.',
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
          'Let\'s speak together! ❤️',
          'Tap here to open MemoMate and call your caregiver now.',
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
    for (int id = 201; id <= 208; id++) {
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
              'medicine_reminder_channel',
              'Medicine Reminders',
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
    await flutterLocalNotificationsPlugin.zonedSchedule(
      50,
      "Brain Exercise Time!",
      "Keep your mind sharp with a quick game.",
      _nextInstanceOfTime(10), // Default to 10 AM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'game_reminder_channel',
          'Game Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'game_reminder',
    );
    debugPrint("Daily game reminders scheduled.");
  }

  Future<void> cancelGameReminders() async {
    await flutterLocalNotificationsPlugin.cancel(50);
    debugPrint("Game reminders cancelled.");
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