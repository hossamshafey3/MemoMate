import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/core/widgets/custom_button.dart';
import 'package:gradproj/core/services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // ── Check doctor session first ─────────────────────
    final doctorToken = await AuthStorage.getToken();
    final doctorProfile = await AuthStorage.getProfile();

    if (!mounted) return;

    if (doctorToken != null &&
        doctorToken.isNotEmpty &&
        doctorProfile != null) {
      await AuthStorage.saveLastRole('doctor');
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/doctorHomeScreen',
        arguments: {'profile': doctorProfile, 'token': doctorToken},
      );
      return;
    }

    // ── Check user (caregiver/patient) session ─────────
    final userToken = await AuthStorage.getUserToken();
    final userProfile = await AuthStorage.getUserProfile();

    if (!mounted) return;

    if (userToken != null && userToken.isNotEmpty && userProfile != null) {
      // Restore the last active role (patient or caregiver)
      final lastRole = await AuthStorage.getLastRole();
      if (!mounted) return;

      // Force patient role if launched from a patient notification
      final bool isPatientAction = NotificationService.initialAction == 'open_call_screen' ||
          NotificationService.initialAction == 'open_games_screen' ||
          (NotificationService.initialAction != null && NotificationService.initialAction!.startsWith('take_medicine:'));

      final route = (lastRole == 'patient' || isPatientAction)
          ? '/patientHomeScreen'
          : '/userHomeScreen';

      if (isPatientAction) {
        await AuthStorage.saveLastRole('patient');
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        route,
        arguments: {'profile': userProfile, 'token': userToken},
      );
      return;
    }

    // No session found — stay on splash, show Get Started
    if (mounted) {
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Image.asset('assets/images/MemoMateLogo.png'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(), // Spacer
              Column(
                children: [
                  // Placeholder for the brain/hands image
                  Image.asset('assets/images/MemoMateLogo.png'),

                  SizedBox(height: 40.h),
                  Text(
                    'Together we will make each day\nwith memomate a little easier a\nlittle lighter',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 70.h),
                child: CustomButton(
                  text: 'Get Started',
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/roleSelectionScreen',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
