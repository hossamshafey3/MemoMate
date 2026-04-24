import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';
import 'package:gradproj/features/user/logic/medicines_cubit.dart';
import 'package:gradproj/features/user/logic/medicines_state.dart';

class PatientRemindersTab extends StatelessWidget {
  final String token;
  const PatientRemindersTab({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicinesCubit, MedicinesState>(
      builder: (context, state) {
        final cubit = context.read<MedicinesCubit>();
        final medicines = cubit.currentMedicines;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Reminders',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              if (state is MedicinesLoading && medicines.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (medicines.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 72.r,
                          color: AppColors.secondary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No reminders yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Your caregiver can add reminders for you',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      final med = medicines[index];
                      return _MedicineCard(medicine: med);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final ReminderModel medicine;

  const _MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        leading: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.alarm, color: AppColors.primary),
        ),
        title: Text(
          medicine.name,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 6.h),
            Text(
              'Dose: ${medicine.dose}',
              style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.grey),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.access_time_filled, size: 16.sp, color: AppColors.secondary),
                SizedBox(width: 4.w),
                Text(
                  medicine.time,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp, 
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(Icons.calendar_month, size: 16.sp, color: AppColors.grey),
                SizedBox(width: 4.w),
                Text(
                  medicine.date.split('T').first,
                  style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
