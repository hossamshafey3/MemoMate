// ─────────────────────────────────────────────
//  doctor_register_screen.dart  –  Memomate
//  Screen for new-doctor registration.
// ─────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/services/image_upload_service.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/core/widgets/custom_button.dart';
import 'package:gradproj/core/widgets/custom_text_field.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/doctor/logic/doctor_cubit.dart';
import 'package:image_picker/image_picker.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ───────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _specCtrl = TextEditingController();
  final _degreeCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();

  bool _obscurePassword = true;
  File? _pickedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  final _imagePicker = ImagePicker();
  final _uploadService = ImageUploadService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _specCtrl.dispose();
    _degreeCtrl.dispose();
    _expCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  // ── Pick image from source ─────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;

    setState(() {
      _pickedImage = File(picked.path);
      _uploadedImageUrl = null;
      _isUploading = true;
    });

    try {
      final url = await _uploadService.uploadImage(_pickedImage!);
      setState(() {
        _uploadedImageUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _pickedImage = null;
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Show picker bottom sheet ───────────────────────────────────
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: Text('Gallery', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('Camera', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please pick a profile image first'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return;
    }

    final model = DoctorRegisterModel(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      image: _uploadedImageUrl!,
      specialization: _specCtrl.text.trim(),
      degree: _degreeCtrl.text.trim(),
      experience: _expCtrl.text.trim(),
      about: _aboutCtrl.text.trim(),
    );

    context.read<DoctorCubit>().registerDoctor(model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<DoctorCubit, DoctorState>(
        listener: (context, state) {
          if (state is DoctorSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Account created successfully 🎉'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/doctorLoginScreen',
              ModalRoute.withName('/roleSelectionScreen'),
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
                        onPressed: () => Navigator.pop(context),
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

                        // ── Title ───────────────────────────────
                        Center(
                          child: Text(
                            'Doctor Registration',
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
                            'Complete your profile to join Memomate',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ── Profile Image Picker ─────────────────
                        Center(
                          child: GestureDetector(
                            onTap: _isUploading ? null : _showImageSourceSheet,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 52.r,
                                  backgroundColor: AppColors.secondary
                                      .withValues(alpha: 0.3),
                                  backgroundImage: _pickedImage != null
                                      ? FileImage(_pickedImage!)
                                      : null,
                                  child: _pickedImage == null
                                      ? Icon(
                                          Icons.person,
                                          size: 48.sp,
                                          color: AppColors.primary,
                                        )
                                      : null,
                                ),
                                // Upload indicator or camera badge
                                Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _isUploading
                                      ? SizedBox(
                                          width: 16.w,
                                          height: 16.w,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                        )
                                      : Icon(
                                          _uploadedImageUrl != null
                                              ? Icons.check
                                              : Icons.camera_alt,
                                          color: Colors.white,
                                          size: 16.sp,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Center(
                          child: Text(
                            _isUploading
                                ? 'Uploading image...'
                                : _uploadedImageUrl != null
                                ? 'Image uploaded ✓'
                                : 'Tap to add profile photo',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: _uploadedImageUrl != null
                                  ? AppColors.primary
                                  : AppColors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ── Name ────────────────────────────────
                        CustomTextField(
                          controller: _nameCtrl,
                          labelText: 'Full Name',
                          hintText: 'e.g. Dr. Mazen Ahmed',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Name is required'
                              : null,
                        ),
                        SizedBox(height: 16.h),

                        // ── Email ───────────────────────────────
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
                        SizedBox(height: 16.h),

                        // ── Password ────────────────────────────
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
                        SizedBox(height: 16.h),

                        // ── Specialization ──────────────────────
                        CustomTextField(
                          controller: _specCtrl,
                          labelText: 'Specialization',
                          hintText: 'e.g. Dermatologist',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Specialization is required'
                              : null,
                        ),
                        SizedBox(height: 16.h),

                        // ── Degree ──────────────────────────────
                        CustomTextField(
                          controller: _degreeCtrl,
                          labelText: 'Degree',
                          hintText: 'e.g. MBBS, MD Dermatology',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Degree is required'
                              : null,
                        ),
                        SizedBox(height: 16.h),

                        // ── Experience ──────────────────────────
                        CustomTextField(
                          controller: _expCtrl,
                          labelText: 'Experience',
                          hintText: 'e.g. 7 Years',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Experience is required'
                              : null,
                        ),
                        SizedBox(height: 16.h),

                        // ── About ───────────────────────────────
                        CustomTextField(
                          controller: _aboutCtrl,
                          labelText: 'About',
                          hintText: 'Brief bio about your expertise...',
                          keyboardType: TextInputType.multiline,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'About is required'
                              : null,
                        ),
                        SizedBox(height: 28.h),

                        // ── Submit Button ────────────────────────
                        state is DoctorLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : CustomButton(
                                text: 'Register',
                                onPressed: _submit,
                              ),

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
