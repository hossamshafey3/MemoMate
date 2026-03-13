import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';

import 'package:gradproj/core/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  final String userType;

  const WelcomeScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder for the heart/people image
              SizedBox(
                width: 200.w,
                height: 200.h,
                child: Image.asset('assets/images/WelcomeLogo.png'),
              ),
              SizedBox(height: 20.h),
              Text(
                'Welcome',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Register in minutes and enjoy a unique experience',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 40.h),
              CustomButton(
                text: 'sign up',
                onPressed: () {
                  if (userType.toLowerCase() == 'doctor') {
                    Navigator.pushNamed(context, '/doctorRegisterScreen');
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/signUpScreen',
                      arguments: userType,
                    );
                  }
                },
              ),
              SizedBox(height: 20.h),
              CustomButton(
                text: 'Login',
                backgroundColor: AppColors.white,
                textColor: AppColors.primary,
                borderColor: AppColors.primary,
                onPressed: () {
                  if (userType.toLowerCase() == 'doctor') {
                    Navigator.pushNamed(context, '/doctorLoginScreen');
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/loginScreen',
                      arguments: userType,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
