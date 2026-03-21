import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:gradproj/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
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
          ],
          child: MaterialApp(
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
