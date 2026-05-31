// ─────────────────────────────────────────────
//  doctor_login_screen.dart  –  Memomate
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/core/widgets/custom_button.dart';
import 'package:gradproj/core/widgets/custom_text_field.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/doctor/logic/doctor_cubit.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
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

    context.read<DoctorCubit>().loginDoctor(
      DoctorLoginModel(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<DoctorCubit, DoctorState>(
        listener: (context, state) async {
          if (state is DoctorLoginSuccess) {
            // Save session for auto-login on next launch
            await AuthStorage.saveSession(
              token: state.token,
              profile: state.profile,
            );
            await AuthStorage.saveLastRole('doctor');
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/doctorHomeScreen',
              (route) => false,
              arguments: {'profile': state.profile, 'token': state.token},
            );
          } else if (state is DoctorFailure) {
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
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Top decoration ─────────────────────────────
                Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(100.r),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.w, top: 40.h),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(
                              context,
                              '/roleSelectionScreen',
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),

                        // ── Title ────────────────────────────────
                        Center(
                          child: Text(
                            'Doctor Login',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Center(
                          child: Text(
                            'Welcome back! Please sign in to continue',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),

                        // ── Doctor icon ───────────────────────────
                        Center(
                          child: CircleAvatar(
                            radius: 48.r,
                            backgroundColor: AppColors.secondary.withValues(
                              alpha: 0.3,
                            ),
                            child: Icon(
                              Icons.medical_services_rounded,
                              size: 48.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // ── Email ────────────────────────────────
                        CustomTextField(
                          controller: _emailCtrl,
                          labelText: 'Email',
                          hintText: 'doctor@example.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),

                        // ── Password ─────────────────────────────
                        CustomTextField(
                          controller: _passwordCtrl,
                          labelText: 'Password',
                          hintText: 'Enter your password',
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
                              return 'Password is required';
                            }
                            if (v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32.h),

                        // ── Login Button ─────────────────────────
                        state is DoctorLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : CustomButton(text: 'Login', onPressed: _submit),

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
