// ─────────────────────────────────────────────────────────────────────────────
//  doctor_details_screen.dart  –  Memomate
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/core/widgets/custom_button.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/core/services/auth_storage.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final DoctorProfile doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 20.r,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Doctor details',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.primary,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Doctor Info Card ──────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Image Part
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 220.h,
                      color: AppColors.primary.withValues(alpha: 0.05),
                      child: doctor.image.isNotEmpty
                          ? Image.network(doctor.image, fit: BoxFit.cover)
                          : Icon(
                              Icons.person,
                              size: 80.r,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                  // Name and Rating Bar
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name.startsWith('Dr.')
                                ? doctor.name
                                : 'Dr. ${doctor.name}',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.yellow.shade700,
                              size: 20.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '4.7', // Hardcoded rating placeholder as requested
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(321 reviews)', // Hardcoded reviews placeholder
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // ── Four Stats Row ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  icon: Icons.person,
                  value:
                      '${doctor.patients.isNotEmpty ? doctor.patients.length : "112"}+',
                  label: 'Patients',
                ),
                _StatItem(
                  icon: Icons.edit_document,
                  value: doctor.experience.isNotEmpty
                      ? doctor.experience
                      : '5+ Years',
                  label: 'Experience',
                ),
                _StatItem(icon: Icons.star, value: '4.7', label: 'Rating'),
                _StatItem(
                  icon: Icons.chat_bubble_rounded,
                  value: '200+',
                  label: 'Reviews',
                ),
              ],
            ),
            SizedBox(height: 30.h),

            // ── About ─────────────────────────────────────────
            Text(
              'About:',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              doctor.about.isNotEmpty
                  ? doctor.about
                  : 'Dr. ${doctor.name} is a caring doctor who specializes in Alzheimer\'s disease and memory problems. She helps patients and their families understand the condition and provides gentle care, guidance.',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: AppColors
                    .primary, // Using primary color as described in image
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 30.h),

            // ── Contact ───────────────────────────────────────
            Text(
              'Contact:',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final profile = await AuthStorage.getUserProfile();
                    if (profile == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error: Could not retrieve active user session.')),
                        );
                      }
                      return;
                    }
                    if (context.mounted) {
                      Navigator.pushNamed(
                        context,
                        '/chatScreen',
                        arguments: {
                          'currentUserId': profile.id,
                          'receiverId': doctor.id,
                          'receiverName': doctor.name.startsWith('Dr.') ? doctor.name : 'Dr. ${doctor.name}',
                          'receiverImage': doctor.image,
                          'receiverSpecialization': doctor.specialization.isNotEmpty ? doctor.specialization : 'Medical Consultant',
                          'doctorId': doctor.id,
                          'patientId': profile.id,
                          'senderRole': 'patient',
                        },
                      );
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  label: Text(
                    'Chat',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.black, size: 22.r),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.primary),
        ),
      ],
    );
  }
}
