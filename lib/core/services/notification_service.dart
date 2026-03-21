import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      print('Could not get local timezone: $e');
    }

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
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap if needed
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Used for testing if notifications work at all',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    
    await flutterLocalNotificationsPlugin.show(
      9999,
      'Test Notification',
      'If you see this, the notification system is working!',
      platformDetails,
    );
  }

  Future<void> scheduleMedicineReminders(List<ReminderModel> medicines) async {
    // Clear all previously scheduled notifications to avoid duplicates
    await flutterLocalNotificationsPlugin.cancelAll();

    final now = DateTime.now();

    for (var medicine in medicines) {
      if (medicine.time.isEmpty) continue;

      try {
        final timeStr = medicine.time.trim();
        DateTime parsedTime;
        try {
          parsedTime = DateFormat('hh:mm a', 'en_US').parse(timeStr);
        } catch (_) {
          try {
            parsedTime = DateFormat('h:mm a', 'en_US').parse(timeStr);
          } catch (_) {
            try {
              parsedTime = DateFormat('HH:mm').parse(timeStr);
            } catch (_) {
              parsedTime = DateFormat.jm().parse(timeStr);
            }
          }
        }

        // Construct the full trigger time for today or the specified date
        // Assuming reminders should be daily or based on the date. 
        // Let's create a daily alarm starting from the 'date' if the time hasn't passed today.
        
        var scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          parsedTime.hour,
          parsedTime.minute,
        );

        if (scheduledTime.isBefore(now)) {
          // If the time has already passed today, schedule for tomorrow
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

        final androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'medicine_alarm_channel',
          'Medicine Alarms',
          channelDescription: 'Persistent alarms to take medicines',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          additionalFlags: Int32List.fromList(<int>[4]), // FLAG_INSISTENT Makes the sound loop
        );

        const DarwinNotificationDetails iOSPlatformChannelSpecifics =
            DarwinNotificationDetails();

        final platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );

        // Use the hashCode of the medicine ID as a unique notification ID
        final notificationId = medicine.id.hashCode;

        print('DEBUG: Scheduling ${medicine.name} at $tzDateTime');

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          'Time for your medicine!',
          'Take ${medicine.dose} of ${medicine.name}',
          tzDateTime,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // Daily repeat at that time
        );
        print('DEBUG: Successfully scheduled ${medicine.name} for $tzDateTime');
      } catch (e) {
        // Ignore parse errors for badly formatted dates
        print('Error scheduling notification: $e');
      }
    }
  }

  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
