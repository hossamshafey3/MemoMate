// ─────────────────────────────────────────────────────────────────────────────
//  doctor_details_screen.dart  –  Memomate
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final DoctorProfile doctor;
  final bool fromChat;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
    this.fromChat = false,
  });

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
                          ? Stack(
                              children: [
                                // Blurred background
                                Positioned.fill(
                                  child: Image.network(
                                    doctor.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                    child: Container(
                                      color: Colors.black.withValues(alpha: 0.15),
                                    ),
                                  ),
                                ),
                                // Main image fully visible without cropping
                                Center(
                                  child: Image.network(
                                    doctor.image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            )
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (doctor.degree.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              doctor.degree,
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                        Text(
                          doctor.name.startsWith('Dr.')
                              ? doctor.name
                              : 'Dr. ${doctor.name}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        if (doctor.specialization.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(
                            doctor.specialization,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
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
                  icon: Icons.people_outline,
                  value: '${doctor.patients.length}',
                  label: 'Patients',
                ),
                _StatItem(
                  icon: Icons.work_outline,
                  value: doctor.experience.isNotEmpty ? doctor.experience : 'N/A',
                  label: 'Experience',
                ),
                _StatItem(
                  icon: Icons.school_outlined,
                  value: doctor.degree.isNotEmpty ? _getShortDegree(doctor.degree) : 'N/A',
                  label: 'Degree',
                ),
                _StatItem(
                  icon: Icons.verified_user_outlined,
                  value: doctor.available ? 'Active' : 'Offline',
                  label: 'Status',
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
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 30.h),

            // ── Contact & Availability ──────────────────────────
            Text(
              'Contact Info:',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.email_outlined, color: AppColors.primary, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          doctor.email,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24.h, color: Colors.grey.shade200),
                  Row(
                    children: [
                      Icon(
                        doctor.available ? Icons.circle : Icons.circle_outlined,
                        color: doctor.available ? Colors.green : Colors.grey,
                        size: 16.sp,
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        doctor.available ? 'Available for consultation' : 'Not available right now',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
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
      bottomNavigationBar: FutureBuilder<UserProfile?>(
        future: AuthStorage.getUserProfile(),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final isWaiting = snapshot.connectionState == ConnectionState.waiting;
          final isAccepted = profile != null && doctor.patients.contains(profile.id);
          final isPending = profile != null && doctor.requests.contains(profile.id);

          return SafeArea(
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
                  if (fromChat || isAccepted)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (fromChat) {
                            Navigator.pop(context);
                            return;
                          }
                          if (profile == null) return;
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
                              'doctorModel': doctor,
                            },
                          );
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
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: null, // Disabled
                        icon: Icon(
                          isWaiting
                              ? Icons.sync
                              : (isPending ? Icons.hourglass_empty_rounded : Icons.lock_outline_rounded),
                          color: Colors.white70,
                        ),
                        label: Text(
                          isWaiting
                              ? 'Loading...'
                              : (isPending ? 'Pending Approval' : 'Not Connected'),
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
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
          );
        },
      ),
    );
  }

  String _getShortDegree(String degree) {
    if (degree.isEmpty) return 'N/A';
    final RegExp splitter = RegExp(r'\b(in|of)\b|[-,\/]', caseSensitive: false);
    final parts = degree.split(splitter);
    if (parts.isNotEmpty) {
      final short = parts[0].trim();
      if (short.isNotEmpty) return short;
    }
    return degree;
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
        SizedBox(
          width: 80.w,
          child: Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
