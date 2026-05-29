import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';
import 'package:gradproj/features/user/logic/medicines_cubit.dart';
import 'package:gradproj/features/user/logic/medicines_state.dart';
import 'package:gradproj/core/services/medicine_storage.dart';

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
                  'Medicines',
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
                          'No medicines yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Your caregiver can add medicines for you',
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

class _MedicineCard extends StatefulWidget {
  final ReminderModel medicine;

  const _MedicineCard({required this.medicine});

  @override
  State<_MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<_MedicineCard> {
  bool _isTaken = false;

  @override
  void initState() {
    super.initState();
    _loadTakenStatus();
  }

  @override
  void didUpdateWidget(covariant _MedicineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.medicine.id != widget.medicine.id ||
        oldWidget.medicine.name != widget.medicine.name) {
      _loadTakenStatus();
    }
  }

  Future<void> _loadTakenStatus() async {
    final taken = await MedicineStorage.isTaken(widget.medicine.id, widget.medicine.name);
    if (mounted) {
      setState(() {
        _isTaken = taken;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isTaken ? 0.75 : 1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _isTaken 
                  ? Colors.green.withValues(alpha: 0.05)
                  : AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: _isTaken 
                  ? Colors.green.withValues(alpha: 0.1) 
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isTaken ? Icons.check_circle_rounded : Icons.alarm, 
              color: _isTaken ? Colors.green : AppColors.primary,
            ),
          ),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _isTaken ? AppColors.grey : AppColors.black,
              decoration: _isTaken ? TextDecoration.lineThrough : TextDecoration.none,
            ),
            child: Text(widget.medicine.name),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.h),
              Text(
                'Dose: ${widget.medicine.dose}',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp, 
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled, 
                    size: 16.sp, 
                    color: _isTaken ? AppColors.grey : AppColors.secondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    widget.medicine.time,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp, 
                      fontWeight: FontWeight.w600,
                      color: _isTaken ? AppColors.grey : AppColors.secondary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(Icons.calendar_month, size: 16.sp, color: AppColors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    widget.medicine.date.split('T').first,
                    style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.grey),
                  ),
                ],
              ),
            ],
          ),
          trailing: GestureDetector(
            onTap: () async {
              final newValue = !_isTaken;
              setState(() {
                _isTaken = newValue;
              });
              await MedicineStorage.setTaken(widget.medicine.id, widget.medicine.name, newValue);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isTaken ? Colors.green : Colors.transparent,
                border: Border.all(
                  color: _isTaken ? Colors.green : AppColors.primary.withValues(alpha: 0.5),
                  width: 2.r,
                ),
                boxShadow: _isTaken
                    ? [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: _isTaken
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16.r,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
