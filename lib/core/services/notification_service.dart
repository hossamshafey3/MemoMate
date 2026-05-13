import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';


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
        if (response.payload == 'game_reminder') {
          // Navigation logic can be added here using navigatorKey
        }
      },
    );

    // Request notification permissions for Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      // Also request exact alarm permission if needed (optional, depends on use case)
      // Note: SCHEDULE_EXACT_ALARM is already in Manifest.
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