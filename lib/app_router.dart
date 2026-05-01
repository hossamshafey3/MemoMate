import 'package:flutter/material.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';
import 'package:gradproj/features/user/presentation/screens/doctor_details_screen.dart';
import 'package:gradproj/features/user/presentation/screens/user_edit_profile_screen.dart';
import 'package:gradproj/features/user/presentation/screens/user_home_screen.dart';
import 'package:gradproj/features/user/presentation/screens/user_login_screen.dart';
import 'package:gradproj/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:gradproj/features/user/presentation/screens/user_sign_up_screen.dart';
import 'package:gradproj/features/auth/presentation/screens/splash_screen.dart';
import 'package:gradproj/features/auth/presentation/screens/welcome_screen.dart';
import 'package:gradproj/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:gradproj/features/doctor/presentation/screens/doctor_login_screen.dart';
import 'package:gradproj/features/doctor/presentation/screens/doctor_register_screen.dart';
import 'package:gradproj/features/user/presentation/screens/patient_home_screen.dart';
import 'package:gradproj/features/memory_games/presentation/screens/memory_card_game_screen.dart';
import 'package:gradproj/features/memory_games/presentation/screens/number_memory_screen.dart';
import 'package:gradproj/features/user/presentation/screens/caregiver_location_screen.dart';

class Routes {
  static const String splashScreen = '/';
  static const String roleSelectionScreen = '/roleSelectionScreen';
  static const String welcomeScreen = '/welcomeScreen';
  static const String loginScreen = '/loginScreen';
  static const String userHomeScreen = '/userHomeScreen';
  static const String userEditProfileScreen = '/userEditProfileScreen';
  static const String doctorDetailsScreen = '/doctorDetailsScreen';
  static const String signUpScreen = '/signUpScreen';
  static const String doctorRegisterScreen = '/doctorRegisterScreen';
  static const String doctorLoginScreen = '/doctorLoginScreen';
  static const String doctorHomeScreen = '/doctorHomeScreen';
  static const String patientHomeScreen = '/patientHomeScreen';
  static const String memoryCardGameScreen = '/memoryCardGameScreen';
  static const String numberMemoryScreen = '/numberMemoryScreen';
  static const String caregiverLocationScreen = '/caregiverLocationScreen';
}

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.roleSelectionScreen:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case Routes.welcomeScreen:
        final userType = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => WelcomeScreen(userType: userType),
        );
      case Routes.loginScreen:
        final userType = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => UserLoginScreen(userType: userType),
        );
      case Routes.signUpScreen:
        return MaterialPageRoute(builder: (_) => const UserSignUpScreen());
      case Routes.userHomeScreen:
        final args = settings.arguments as Map<String, dynamic>;
        final profile = args['profile'] as UserProfile;
        final token = args['token'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => UserHomeScreen(profile: profile, token: token),
        );
      case Routes.userEditProfileScreen:
        final args = settings.arguments as Map<String, dynamic>;
        final profile = args['profile'] as UserProfile;
        final token = args['token'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => UserEditProfileScreen(profile: profile, token: token),
        );
      case Routes.doctorDetailsScreen:
        final doctor = settings.arguments as DoctorProfile;
        return MaterialPageRoute(
          builder: (_) => DoctorDetailsScreen(doctor: doctor),
        );
      case Routes.doctorRegisterScreen:
        return MaterialPageRoute(builder: (_) => const DoctorRegisterScreen());
      case Routes.doctorLoginScreen:
        return MaterialPageRoute(builder: (_) => const DoctorLoginScreen());
      case Routes.doctorHomeScreen:
        final args = settings.arguments as Map<String, dynamic>;
        final profile = args['profile'] as DoctorProfile;
        final token = args['token'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => DoctorHomeScreen(doctor: profile, token: token),
        );
      case Routes.patientHomeScreen:
        final args = settings.arguments as Map<String, dynamic>;
        final profile = args['profile'] as UserProfile;
        final token = args['token'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => PatientHomeScreen(profile: profile, token: token),
        );
      case Routes.memoryCardGameScreen:
        return MaterialPageRoute(builder: (_) => const MemoryCardGameScreen());
      case Routes.numberMemoryScreen:
        return MaterialPageRoute(builder: (_) => const NumberMemoryScreen());
      case Routes.caregiverLocationScreen:
        final token = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CaregiverLocationScreen(token: token),
        );
      default:
        return null;
    }
  }
}
