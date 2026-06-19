// ─────────────────────────────────────────────────────────────────────────────
//  user_login_screen.dart  –  Memomate
//  Login screen for caregiver/user.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/core/widgets/custom_button.dart';
import 'package:gradproj/core/widgets/custom_text_field.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';
import 'package:gradproj/features/user/logic/user_cubit.dart';

class UserLoginScreen extends StatefulWidget {
  final String userType;
  const UserLoginScreen({super.key, required this.userType});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.userType.toLowerCase() == 'user') {
      context.read<UserCubit>().loginUser(
        UserLoginModel(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) async {
        if (state is UserLoginSuccess) {
          await AuthStorage.saveUserSession(
            token: state.token,
            profile: state.profile,
          );
          final lastRole = await AuthStorage.getLastRole();
          String destinationRoute = '/patientHomeScreen';
          if (lastRole == 'caregiver') {
            destinationRoute = '/userHomeScreen';
          } else {
            await AuthStorage.saveLastRole('patient');
          }
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            destinationRoute,
            (route) => false,
            arguments: {'profile': state.profile, 'token': state.token},
          );
        } else if (state is UserFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ── Decorative circles ────────────────────────────
            Positioned(
              top: -60.r,
              right: -60.r,
              child: Container(
                width: 200.r,
                height: 200.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
            ),
            Positioned(
              bottom: -60.r,
              left: -60.r,
              child: Container(
                width: 200.r,
                height: 200.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
            ),

            // ── Main content ──────────────────────────────────
            SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 60.h),
                            // Title
                            Center(
                              child: Text(
                                'Log in',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Center(
                              child: Text(
                                'Please type your email and password\nto enter the application',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),
                            // Email
                            Text(
                              'Email address',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            CustomTextField(
                              controller: _emailCtrl,
                              hintText: 'enter your email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (!v.contains('@')) return 'Invalid email';
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            // Password
                            Text(
                              'Password',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            CustomTextField(
                              controller: _passwordCtrl,
                              hintText: 'enter your password',
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.grey,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            // Login button
                            BlocBuilder<UserCubit, UserState>(
                              builder: (context, state) {
                                return state is UserLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : CustomButton(
                                        text: 'Login',
                                        onPressed: _submit,
                                      );
                              },
                            ),
                            SizedBox(height: 20.h),
                            // Sign up row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "You don't have an account? ",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.grey,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/signUpScreen',
                                    arguments: widget.userType,
                                  ),
                                  child: Text(
                                    'sign up',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primary,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
