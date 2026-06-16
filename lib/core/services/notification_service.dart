import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';
import 'package:gradproj/core/services/medicine_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Broadcast stream controller to notify the UI about notification action taps
  static final StreamController<String> _actionController = StreamController<String>.broadcast();
  static Stream<String> get notificationActions => _actionController.stream;

  // Track the action that launched or was tapped in the background
  static String? initialAction;

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  /// Rebuild the Notification Service and configure it from scratch
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    // Explicitly configure timezone at init
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String currentTimeZone = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      debugPrint('🔔 [NotificationService.initialize] Timezone successfully set to: $currentTimeZone');
    } catch (e) {
      debugPrint('⚠️ [NotificationService.initialize] Error initializing timezone: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        debugPrint('🔔 [NotificationService] Notification tapped with payload: $payload');
        
        final launchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
        final bool isLaunch = launchDetails != null && launchDetails.didNotificationLaunchApp;

        if (payload != null && payload.isNotEmpty) {
          initialAction = payload;
          _actionController.add(payload);
        }

        if (isLaunch) {
          debugPrint('🔔 [NotificationService] Skipping callback navigation: App launch is handled by startup flow.');
          return;
        }

        if (payload == 'open_call_screen' || payload == 'open_games_screen' || (payload != null && payload.startsWith('take_medicine:'))) {
          try {
            final userToken = await AuthStorage.getUserToken();
            final userProfile = await AuthStorage.getUserProfile();
            if (userToken != null && userToken.isNotEmpty && userProfile != null) {
              if (payload == 'open_call_screen') {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/patientHomeScreen',
                  (route) => false,
                  arguments: {'profile': userProfile, 'token': userToken},
                );
              } else if (payload == 'open_games_screen') {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/patientHomeScreen',
                  (route) => false,
                  arguments: {'profile': userProfile, 'token': userToken},
                );
                // Push GamesHomeScreen on top of patientHomeScreen
                navigatorKey.currentState?.pushNamed('/gamesHomeScreen');
              } else if (payload != null && payload.startsWith('take_medicine:')) {
                final parts = payload.split(':');
                final medId = parts.length > 1 ? parts[1] : '';
                final medName = parts.length > 2 ? parts[2] : '';
                await MedicineStorage.setTaken(medId, medName, true);
                
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/patientHomeScreen',
                  (route) => false,
                  arguments: {'profile': userProfile, 'token': userToken},
                );
              }
            } else {
              // Fallback if not logged in
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/roleSelectionScreen',
                (route) => false,
              );
            }
          } catch (e) {
            debugPrint('⚠️ Navigation on notification tap failed: $e');
          }
        }
      },
    );

    // Get launch details if app was launched from a notification tap
    try {
      final launchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        debugPrint('🔔 [NotificationService] App launched from notification with payload: $payload');
        if (payload != null && payload.isNotEmpty) {
          initialAction = payload;
          if (payload.startsWith('take_medicine:')) {
            final parts = payload.split(':');
            final medId = parts.length > 1 ? parts[1] : '';
            final medName = parts.length > 2 ? parts[2] : '';
            await MedicineStorage.setTaken(medId, medName, true);
            debugPrint('💊 [NotificationService] Terminated launch: marked medicine $medName as taken.');
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Error getting launch details: $e');
    }

    // Setup main high priority channel and request permissions for Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        debugPrint('🔔 [NotificationService.initialize] Creating MemoMate main channel...');
        try {
          const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
            'memomate_reminders',
            'MemoMate Main Channel',
            description: 'Daily reminders and important setup updates.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          );

          const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
            'memomate_alarms',
            'MemoMate Medicine Alarms',
            description: 'Loud alarms for scheduled medicine times.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          );

          await androidPlugin.createNotificationChannel(mainChannel);
          await androidPlugin.createNotificationChannel(alarmChannel);
          debugPrint('🔔 [NotificationService.initialize] Main and Alarm channels created successfully.');
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

  /// Dynamic Welcome and Switch notification trigger (ID 99)
  /// Fired instantly when user switches roles or opens the app
  Future<void> showExploreNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'memomate_reminders',
      'MemoMate Main Channel',
      channelDescription: 'Daily reminders and important setup updates.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    try {
      debugPrint('🔔 [NotificationService.showExploreNotification] Triggering ID 99 notification...');
      await flutterLocalNotificationsPlugin.show(
        99,
        "Let's Explore MemoMate ✅",
        "Your profile is set! Let's start your journey together.",
        details,
      );
      debugPrint('🔔 [NotificationService.showExploreNotification] ID 99 welcome notification successfully sent.');
    } catch (e) {
      debugPrint('❌ [NotificationService.showExploreNotification] Failed to send Welcome notification: $e');
    }
  }

  /// Auto-schedule the 8 daily notifications (5 calls + 3 brain games)
  static Future<void> initAndSchedule() async {
    final service = NotificationService();
    try {
      await service.scheduleAllDailyReminders();
    } catch (e) {
      debugPrint('❌ [NotificationService.initAndSchedule] Failed scheduling: $e');
    }
  }

  /// Consolidate scheduling of all daily reminders safely
  Future<void> scheduleAllDailyReminders() async {
    // 5 Times for Caregiver Calls: (09:00, 13:00, 17:00, 21:00, 22:30)
    // IDs 1 to 5 to avoid overlap
    final List<Map<String, dynamic>> callTimes = [
      {'id': 1, 'hour': 9,  'minute': 0},
      {'id': 2, 'hour': 13, 'minute': 0},
      {'id': 3, 'hour': 17, 'minute': 0},
      {'id': 4, 'hour': 21, 'minute': 0},
      {'id': 5, 'hour': 22, 'minute': 30},
    ];

    // 3 Times for Brain Games: (11:00, 15:00, 19:00)
    // IDs 6 to 8
    final List<Map<String, dynamic>> gameTimes = [
      {'id': 6, 'hour': 11, 'minute': 0},
      {'id': 7, 'hour': 15, 'minute': 0},
      {'id': 8, 'hour': 19, 'minute': 0},
    ];

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'memomate_reminders',
      'MemoMate Main Channel',
      channelDescription: 'Daily reminders and important setup updates.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    // Schedule caregiver calls
    for (final entry in callTimes) {
      final int id = entry['id'] as int;
      final int hour = entry['hour'] as int;
      final int minute = entry['minute'] as int;
      
      try {
        final tz.TZDateTime scheduledTime = _nextInstanceOfDetailedTime(hour, minute);
        debugPrint('🔔 [NotificationService.scheduleAllDailyReminders] Scheduling Call Reminder ID $id for $scheduledTime...');
        
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          "Let's speak together! ❤️",
          "Tap here to call your caregiver and share your day.",
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'open_call_screen',
        );
      } catch (e) {
        debugPrint('❌ [NotificationService.scheduleAllDailyReminders] Failed call reminder ID $id: $e');
      }
    }

    // Schedule brain games
    for (final entry in gameTimes) {
      final int id = entry['id'] as int;
      final int hour = entry['hour'] as int;
      final int minute = entry['minute'] as int;
      
      try {
        final tz.TZDateTime scheduledTime = _nextInstanceOfDetailedTime(hour, minute);
        debugPrint('🔔 [NotificationService.scheduleAllDailyReminders] Scheduling Game Reminder ID $id for $scheduledTime...');
        
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          "Brain Exercise Time! 🧠",
          "Keep your mind sharp! Tap to play your favorite games.",
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'open_games_screen',
        );
      } catch (e) {
        debugPrint('❌ [NotificationService.scheduleAllDailyReminders] Failed game reminder ID $id: $e');
      }
    }

    debugPrint('🔔 [NotificationService.scheduleAllDailyReminders] Consolidate daily reminders schedule completed.');
  }

  /// Cancel all daily reminders (IDs 1-8)
  Future<void> cancelDailyReminders() async {
    for (int id = 1; id <= 8; id++) {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
    debugPrint('🔔 [NotificationService.cancelDailyReminders] All daily reminders cancelled.');
  }

  /// Schedule daily game reminders (IDs 6-8) specifically for PatientGamesTab toggle
  Future<void> scheduleDailyGameReminders() async {
    final List<Map<String, dynamic>> gameTimes = [
      {'id': 6, 'hour': 11, 'minute': 0},
      {'id': 7, 'hour': 15, 'minute': 0},
      {'id': 8, 'hour': 19, 'minute': 0},
    ];

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'memomate_reminders',
      'MemoMate Main Channel',
      channelDescription: 'Daily reminders and important setup updates.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    for (final entry in gameTimes) {
      final int id = entry['id'] as int;
      final int hour = entry['hour'] as int;
      final int minute = entry['minute'] as int;
      
      try {
        final tz.TZDateTime scheduledTime = _nextInstanceOfDetailedTime(hour, minute);
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          "Brain Exercise Time! 🧠",
          "Keep your mind sharp! Tap to play your favorite games.",
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'open_games_screen',
        );
      } catch (e) {
        debugPrint('❌ [NotificationService] Failed to schedule game reminder ID $id: $e');
      }
    }
    debugPrint('🔔 [NotificationService] Game reminders scheduled successfully via toggle.');
  }

  /// Cancel daily game reminders (IDs 6-8) specifically for PatientGamesTab toggle
  Future<void> cancelGameReminders() async {
    for (int id = 6; id <= 8; id++) {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
    debugPrint('🔔 [NotificationService] Game reminders cancelled successfully via toggle.');
  }

  /// Cancel all notifications completely
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint("🔔 [NotificationService.cancelAllNotifications] All notifications cancelled.");
  }

  // --- Medicine Reminders (Kept for compatibility with MedicinesCubit) ---
  Future<void> scheduleMedicineReminders(List<ReminderModel> medicines) async {
    // Cancel existing medicine notifications (IDs 100-200)
    for (int i = 100; i < 200; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }

    for (int i = 0; i < medicines.length; i++) {
      final medicine = medicines[i];
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
          NotificationDetails(
            android: AndroidNotificationDetails(
              'memomate_alarms',
              'MemoMate Medicine Alarms',
              channelDescription: 'Loud alarms for scheduled medicine times.',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              category: AndroidNotificationCategory.alarm,
              audioAttributesUsage: AudioAttributesUsage.alarm,
              vibrationPattern: Int64List.fromList([0, 1000, 1000, 1000, 1000, 1000, 1000, 1000]),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'take_medicine:${medicine.id}:${medicine.name}',
        );
      } catch (e) {
        debugPrint("❌ [NotificationService] Error scheduling medicine ${medicine.name}: $e");
      }
    }
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

  /// Real-time chat notification trigger
  Future<void> showChatNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'memomate_chat',
      'MemoMate Chat Channel',
      channelDescription: 'Real-time notifications for incoming medical and caregiver messages.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    try {
      debugPrint('🔔 [NotificationService.showChatNotification] Triggering chat notification...');
      await flutterLocalNotificationsPlugin.show(
        1001, // Unique ID for chat notification
        title,
        body,
        details,
        payload: 'open_chat_screen',
      );
      debugPrint('🔔 [NotificationService.showChatNotification] Chat notification successfully sent.');
    } catch (e) {
      debugPrint('❌ [NotificationService.showChatNotification] Failed to send chat notification: $e');
    }
  }
}