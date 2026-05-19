import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:gradproj/app_router.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/data/data_sources/user_remote_data_source.dart';
import 'package:gradproj/features/user/data/repositories/user_repository_impl.dart';
import 'package:gradproj/features/user/logic/user_cubit.dart';
import 'package:gradproj/features/doctor/data/data_sources/doctor_remote_data_source.dart';
import 'package:gradproj/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:gradproj/features/doctor/logic/doctor_cubit.dart';
import 'package:gradproj/features/user/logic/doctors_list_cubit.dart';
import 'package:gradproj/features/user/logic/medicines_cubit.dart';
import 'package:gradproj/features/user/logic/family_tree_cubit.dart';
import 'package:gradproj/features/user/logic/location_cubit.dart';
import 'package:gradproj/features/user/logic/call_cubit.dart';
import 'package:gradproj/core/services/notification_service.dart';
import 'package:gradproj/core/services/location_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

void main() async {
  // Ensure WidgetsFlutterBinding.ensureInitialized(); is the very first line
  WidgetsFlutterBinding.ensureInitialized();

  // ── Step 1-3: Timezone & Notification Initializations (Zero-Crash Insurance) ──
  try {
    // ── Timezone database initialization ──────────────────
    try {
      tz_data.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      debugPrint('⚠️ Timezone initialization failed (non-fatal): $e');
    }

    // ── Local notifications plugin initialization ─────────
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint('⚠️ NotificationService.initialize() failed (non-fatal): $e');
    }

    // ── Schedule 8 daily reminders and welcome trigger ────
    try {
      await NotificationService.initAndSchedule();
    } catch (e) {
      debugPrint('⚠️ NotificationService.initAndSchedule() failed (non-fatal): $e');
    }

    // ── Step 4: Show the Welcome/Explore Notification after 5 seconds ─────
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        await NotificationService().showExploreNotification();
      } catch (e) {
        debugPrint('⚠️ ShowExploreNotification failed: $e');
      }
    });
  } catch (e) {
    debugPrint('⚠️ Critical notification/timezone initialization failure (non-fatal): $e');
  }

  // ── Step 5: Start the background location service ─────────────────────────
  try {
    await LocationService.initializeBackgroundService();
  } catch (e) {
    debugPrint('⚠️ LocationService.initializeBackgroundService() failed (non-fatal): $e');
  }

  // Guaranteed to run, ensuring the app UI opens and never locks the user out
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    final doctorDataSource = DoctorRemoteDataSourceImpl(dio);
    final doctorRepository = DoctorRepositoryImpl(doctorDataSource);

    final userDataSource = UserRemoteDataSourceImpl(dio);
    final userRepository = UserRepositoryImpl(userDataSource);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<DoctorCubit>(
              create: (_) => DoctorCubit(doctorRepository),
            ),
            BlocProvider<UserCubit>(create: (_) => UserCubit(userRepository)),
            BlocProvider<DoctorsListCubit>(
              create: (_) => DoctorsListCubit(userRepository),
            ),
            BlocProvider<MedicinesCubit>(
              create: (_) => MedicinesCubit(userRepository),
            ),
            BlocProvider<FamilyTreeCubit>(
              create: (_) => FamilyTreeCubit(userRepository),
            ),
            BlocProvider<LocationCubit>(
              create: (_) => LocationCubit(userRepository),
            ),
            BlocProvider<CallCubit>(
              create: (_) => CallCubit(userRepository),
            ),
          ],
          child: MaterialApp(
            navigatorKey: NotificationService.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Memomate',
            theme: ThemeData(
              primaryColor: AppColors.primary,
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              useMaterial3: true,
            ),
            onGenerateRoute: AppRouter().generateRoute,
            initialRoute: Routes.splashScreen,
          ),
        );
      },
    );
  }
}
